import Foundation

struct UploadFindingEndpoint: APIEndpoint {
    typealias Response = EmptyAPIResponse

    let host: String
    let path = APIConstants.uploadFindingPath
    let method: APIHTTPMethod = .post
    let body: APIRequestBody

    init(host: String, findingBody: FindingRequestBody) {
        self.host = host
        self.body = .json(findingBody)
    }
}

struct UploadFindingImageEndpoint: APIEndpoint {
    typealias Response = FindingImageResponse

    let host: String
    let path = APIConstants.uploadFindingImagePath
    let method: APIHTTPMethod = .post
    let headers: [String: String]
    let body: APIRequestBody

    init(host: String, imageData: Data) {
        let boundary = "Boundary-\(UUID().uuidString)"
        self.host = host
        self.headers = [
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
            "Accept": "*/*",
            "User-Agent": APIConstants.userAgentName
        ]
        self.body = .data(
            Self.multipartBody(
                imageData: imageData,
                fileName: ".jpg",
                boundary: boundary
            )
        )
    }

    private static func multipartBody(imageData: Data, fileName: String, boundary: String) -> Data {
        var body = Data()
        body.appendUTF8("--\(boundary)\r\n")
        body.appendUTF8("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
        body.appendUTF8("Content-Type: image/*\r\n\r\n")
        body.append(imageData)
        body.appendUTF8("\r\n--\(boundary)--\r\n")
        return body
    }
}

private extension Data {
    mutating func appendUTF8(_ string: String) {
        append(string.data(using: .utf8)!)
    }
}
