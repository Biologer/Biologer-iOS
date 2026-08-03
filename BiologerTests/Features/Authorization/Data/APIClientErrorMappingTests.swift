import XCTest
@testable import Biologer

final class APIClientErrorMappingTests: XCTestCase {
    func test_asAPIError_mapsNoInternetRequestFailure() {
        let sut = APIClientError.requestFailed(
            message: "The Internet connection appears to be offline.",
            code: NSURLErrorNotConnectedToInternet
        )

        let error = sut.asAPIError()

        XCTAssertEqual(error.title, ErrorConstant.noInternetConnectionTitle)
        XCTAssertEqual(error.description, ErrorConstant.noInternetConnectionDescription)
        XCTAssertFalse(error.isInternetConnectionAvailable)
    }

    func test_asAPIError_mapsValidationPayloadFirstFieldError() {
        let payload = APIErrorPayload(
            message: "Validation failed",
            error: nil,
            errorDescription: nil,
            status: nil,
            errors: ["email": ["Email has already been taken"]]
        )
        let sut = APIClientError.validationFailed(payload)

        let error = sut.asAPIError()

        XCTAssertEqual(error.title, "Validation failed")
        XCTAssertEqual(error.description, "Email has already been taken")
        XCTAssertTrue(error.isInternetConnectionAvailable)
    }

    func test_asAPIError_mapsOAuthPayloadDescription() {
        let payload = APIErrorPayload(
            message: nil,
            error: "invalid_grant",
            errorDescription: "The user credentials were incorrect.",
            status: nil,
            errors: nil
        )
        let sut = APIClientError.badRequest(payload)

        let error = sut.asAPIError()

        XCTAssertEqual(error.title, "invalid_grant")
        XCTAssertEqual(error.description, "The user credentials were incorrect.")
    }
}
