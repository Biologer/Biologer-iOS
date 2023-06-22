//
//  TaxonService.swift
//  Biologer
//
//  Created by Nikola Popovic on 1.10.21..
//

import Foundation
import BackgroundTasks

public struct TaxonDataResponse: Codable {
    
    let data: [TaxonResponse]
    let meta: TaxonMetaResponse
    
    public struct TaxonResponse: Codable {
        let id: Int
        let name: String?
        let rank: String?
        let rank_level: Int?
        let restricted: Bool?
        let allochthonous: Bool?
        let invasive: Bool?
        let uses_atlas_codes: Bool?
        let ancestors_names: String?
        let can_edit: Bool?
        let can_delete: Bool?
        let rank_translation: String?
        let native_name: String?
        let description: String?
        let translations: [TaxonTranslationsResponse]?
        let stages: [TaxonStagesResponse]?
    }

    public struct TaxonStagesResponse: Codable {
        let id: Int
        let name: String?
        let created_at: String?
        let updated_at: String?
    }
    
    public struct TaxonTranslationsResponse: Codable {
        let id: Int
        //let taxon_id: String?
        let locale: String?
        let native_name: String?
        let description: String?
    }
    
    public struct TaxonMetaResponse: Codable {
        let current_page: Int
        let from: Int?
        let last_page: Int
        let per_page: String?
        let to: Int?
        let total: Int
    }
}

public protocol TaxonService {
    typealias Result = Swift.Result<TaxonDataResponse, APIError>
    var response: Observer<Result>? { get set }
    func getTaxons(currentPage: Int,
                   perPage: Int,
                   updatedAfter: Int64,
                   completion: @escaping (Result) -> Void)
}

public final class RemoteTaxonService: TaxonService{
    public var response: Observer<Result>?
    
    public typealias Result = Swift.Result<TaxonDataResponse, APIError>
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    private var backgoundTask: BGProcessingTask?
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage,
                backgoundTask: BGProcessingTask?) {
        self.client = client
        self.environmentStorage = environmentStorage
        self.backgoundTask = backgoundTask
    }
    
    func completePaginationTask(task: BGProcessingTask) {
        // Perform any necessary cleanup or finalization
        
        // Mark the task as complete
        task.setTaskCompleted(success: true)
    }
    
    func scheduleNextPaginationTask() {
        let taskRequest = BGProcessingTaskRequest(identifier: "com.biologer.paginationBackgroundTask")
        taskRequest.requiresNetworkConnectivity = true
        taskRequest.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            print("Failed to schedule next pagination task: \(error.localizedDescription)")
        }
    }
    
    
    public func getTaxons(currentPage: Int,
                          perPage: Int,
                          updatedAfter: Int64,
                          completion: @escaping (Result) -> Void) {
        
            scheduleNextPaginationTask()
            if let env = environmentStorage.getEnvironment(), let task = backgoundTask {

                var queryParameters: [URLQueryItem] = [URLQueryItem]()
                queryParameters.append(URLQueryItem(name: "page",value: String(currentPage)))
                queryParameters.append(URLQueryItem(name: "per_page",value: String(perPage)))
                queryParameters.append(URLQueryItem(name: "updated_after",value: String(updatedAfter)))
                queryParameters.append(URLQueryItem(name: "withGroupsIds",value: String(false)))
                queryParameters.append(URLQueryItem(name: "ungrouped",value: String(updatedAfter)))

                let request = try! TaxonRequest(host: env.host, queryParameters: queryParameters).asURLRequest()
                client.perform(from: request) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(APIError(description: error.localizedDescription)))
                        task.setTaskCompleted(success: true)
                    case .success(let result):
                        if result.1.statusCode == 200, let response = try? JSONDecoder().decode(TaxonDataResponse.self,
                                                                                        from: result.0) {
                            completion(.success(response))
                            task.setTaskCompleted(success: true)
                        } else {
                            completion(.failure(APIError(description: ErrorConstant.parsingErrorConstant)))
                            task.setTaskCompleted(success: true)
                        }
                    }
                }
            } else {
                completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
                //task.setTaskCompleted(success: true)
            }
    }
    
    private class TaxonRequest: APIRequest {
        
        var method: HTTPMethod = .get
        
        var host: String
        
        var path: String = APIConstants.taxonPath
        
        var queryParameters: [URLQueryItem]? = nil
        
        var body: Data?
        
        var headers: HTTPHeaders?
        
        init(host: String, queryParameters: [URLQueryItem]) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: APIConstants.applicationJson)
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            self.host = host
            self.queryParameters = queryParameters
        }
    }
}

class BackgroundAPIController: NSObject, URLSessionDelegate, URLSessionDownloadDelegate, TaxonService {
    
    public typealias Result = Swift.Result<TaxonDataResponse, APIError>

    private let environmentStorage: EnvironmentStorage
    private let tokenStorage: TokenStorage
    
    public var response: Observer<Result>?
    
    public init(environmentStorage: EnvironmentStorage,
                tokenStorage: TokenStorage) {
        self.environmentStorage = environmentStorage
        self.tokenStorage = tokenStorage
    }

    func getTaxons(currentPage: Int,
                   perPage: Int,
                   updatedAfter: Int64,
                   completion: @escaping (Result) -> Void) {
        
        var session: URLSession!
            
            if let env = self.environmentStorage.getEnvironment() {
                
                var queryParameters: [URLQueryItem] = [URLQueryItem]()
                queryParameters.append(URLQueryItem(name: "page",value: String(currentPage)))
                queryParameters.append(URLQueryItem(name: "per_page",value: String(5)))
                queryParameters.append(URLQueryItem(name: "updated_after",value: String(updatedAfter)))
                queryParameters.append(URLQueryItem(name: "withGroupsIds",value: String(false)))
                queryParameters.append(URLQueryItem(name: "ungrouped",value: String(updatedAfter)))
                
                var tokenParam = ""
                
                if let token = self.tokenStorage.getToken(), !token.accessToken.isEmpty {
                    let accessToken = token.accessToken
                    print("Token from taxon service")
                    tokenParam = "Bearer \(accessToken)"
                    //                mutableRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: HTTPHeaderName.authorization.description)
                }
                
                var request = try! TaxonRequest(host: env.host, queryParameters: queryParameters).asURLRequest()
                request.setValue(tokenParam, forHTTPHeaderField: HTTPHeaderName.authorization.description)
                
                let backgroundConfig = URLSessionConfiguration.background(withIdentifier: "com.biologer.paginationBackgroundTask\(currentPage)")
                session = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: nil)
                
                let downloadTask = session.downloadTask(with: request)
                downloadTask.earliestBeginDate = Date().addingTimeInterval(5)
                downloadTask.resume()
            }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download completed from BACKGROUND")

        do {
            let data = try Data(contentsOf: location)
            print("Downloaded data BACKGROUND: \(String(decoding: data, as: UTF8.self))")
            if let res = try? JSONDecoder().decode(TaxonDataResponse.self,
                                                                            from: data) {
                response?(.success(res))
                getTaxons(currentPage: 2, perPage: 5, updatedAfter: 0) { result in
                    
                }
            } else {
                response?(.failure(APIError(description: ErrorConstant.parsingErrorConstant)))
            }

        } catch {
            response?(.failure(APIError(description: error.localizedDescription)))
            print("Error reading downloaded file BACKGROUND: \(error.localizedDescription)")
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // Handle error
        print("Download error BACKGROUND: \(error?.localizedDescription ?? "Unknown error")")
    }

    private class TaxonRequest: APIRequest {

        var method: HTTPMethod = .get

        var host: String

        var path: String = APIConstants.taxonPath

        var queryParameters: [URLQueryItem]? = nil

        var body: Data?

        var headers: HTTPHeaders?

        init(host: String, queryParameters: [URLQueryItem]) {
            var headers = HTTPHeaders()
            headers.add(name: HTTPHeaderName.contentType, value: APIConstants.applicationJson)
            headers.add(name: HTTPHeaderName.acceept, value: APIConstants.applicationJson)
            self.headers = headers
            self.host = host
            self.queryParameters = queryParameters
        }
    }
}
