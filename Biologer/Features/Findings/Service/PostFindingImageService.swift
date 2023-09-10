//
//  PostFindingImageService.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.11.21..
//

import UIKit

public protocol PostFindingImageService {
    typealias Result = Swift.Result<FindingImageResponse, APIError>
    func uploadFindingImages(taxonImages: TaxonImage,
                   completion: @escaping (Result) -> Void)
}

public final class RemotePostFindingImageService: PostFindingImageService {
    
    public typealias Result = Swift.Result<FindingImageResponse, APIError>
    
    private let client: HTTPClient
    private let environmentStorage: EnvironmentStorage
    
    public init(client: HTTPClient,
                environmentStorage: EnvironmentStorage) {
        self.client = client
        self.environmentStorage = environmentStorage
    }
    
    public func uploadFindingImages(taxonImages: TaxonImage, completion: @escaping (Result) -> Void) {
        if let env = environmentStorage.getEnvironment() {
            let request = try! GetEditProfilePreview(host: env.host, taxonImage: taxonImages).asURLRequest()
            client.perform(from: request) { result in
                switch result {
                case .failure(let error):
                    completion(.failure(APIError(description: error.localizedDescription)))
                case .success(let result):
                    if result.1.statusCode == 200, let response = try? JSONDecoder().decode(FindingImageResponse.self,
                                                                                    from: result.0) {
                        completion(.success(response))
                    } else {
                        if let response = try? JSONDecoder().decode(APIErrorResponse.self,from: result.0) {
                            completion(.failure(APIError(title: response.message, description: "")))
                        } else {
                            completion(.failure(APIError(description: ErrorConstant.parsingErrorConstant)))
                        }
                    }
                }
            }
        } else {
            completion(.failure(APIError(description: ErrorConstant.environmentNotSelected)))
        }
    }
    
    private struct APIErrorResponse: Codable {
        let message: String
    }
    
    private struct GetEditProfilePreview: APIRequest {
        let method: HTTPMethod = .post
        let host: String
        let path = APIConstants.uploadFindingImagePath
        let queryParameters: [URLQueryItem]? = nil
        var body: Data? = nil
        var headers: HTTPHeaders? = nil

        init (host: String, taxonImage: TaxonImage) {
            self.host = host

            var headers = HTTPHeaders()
            let boundary = "Boundary-\("\(UUID().uuidString)")"
            headers.add(name: .contentType, value: "multipart/form-data; boundary=\(boundary)")
            headers.add(name: .acceept, value: "*/*")
            self.headers = headers
            self.body = createBodyWithParameters(parameters: nil,
                                                 filePathKey: "file",
                                                 imageDataKey: taxonImage.image.jpegData(compressionQuality: 0.7)!,
                                                 boundary: boundary,
                                                 imgKey: taxonImage.imageUrl ?? "") as Data
        }

        func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String, imgKey: String) -> NSData {
            let body = NSMutableData();
            
            if parameters != nil {
                for (key, value) in parameters! {
                    body.appendString("--\(boundary)\r\n")
                    body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.appendString("\(value)\r\n")
                }
            }
            
            let filename = "\(imgKey).jpg"
            let mimetype = "image/*"
            
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
            body.appendString( "Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageDataKey as Data)
            body.appendString("\r\n")
            body.appendString("--\(boundary)--\r\n")
            
            return body
        }
        
        func generateBoundaryString() -> String {
            return "Boundary-\(NSUUID().uuidString)"
        }

        }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

func convertFromField(named name: String, value: String, using boundary: String) -> String {
    var fieldString = "--\(boundary)\r\n"
    fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
    fieldString += "\r\n"
    fieldString += "\(value)\r\n"
    
    return fieldString
}
