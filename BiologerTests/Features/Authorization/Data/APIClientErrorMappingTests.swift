import XCTest
@testable import Biologer

final class APIClientErrorMappingTests: XCTestCase {
    func test_asAuthorizationFailure_whenNetworkIsUnavailable_mapsLocalizedOfflineDetails() {
        // Given
        let sut = APIClientError.requestFailed(
            message: "The Internet connection appears to be offline.",
            code: NSURLErrorNotConnectedToInternet
        )

        // When
        let error = sut.asAuthorizationFailure

        // Then
        XCTAssertEqual(error.summary, "API.lb.noInternetError".localized)
        XCTAssertEqual(error.message, "API.lb.noInternetDescriptionError".localized)
        XCTAssertFalse(error.isInternetConnectionAvailable)
    }

    func test_asAuthorizationFailure_whenValidationPayloadContainsFieldError_mapsFirstFieldError() {
        // Given
        let payload = APIErrorPayload(
            message: "Validation failed",
            error: nil,
            errorDescription: nil,
            status: nil,
            errors: ["email": ["Email has already been taken"]]
        )
        let sut = APIClientError.validationFailed(payload)

        // When
        let error = sut.asAuthorizationFailure

        // Then
        XCTAssertEqual(error.summary, "Validation failed")
        XCTAssertEqual(error.message, "Email has already been taken")
        XCTAssertTrue(error.isInternetConnectionAvailable)
    }

    func test_asAuthorizationFailure_whenOAuthPayloadContainsDescription_mapsOAuthDetails() {
        // Given
        let payload = APIErrorPayload(
            message: nil,
            error: "invalid_grant",
            errorDescription: "The user credentials were incorrect.",
            status: nil,
            errors: nil
        )
        let sut = APIClientError.badRequest(payload)

        // When
        let error = sut.asAuthorizationFailure

        // Then
        XCTAssertEqual(error.summary, "invalid_grant")
        XCTAssertEqual(error.message, "The user credentials were incorrect.")
    }
}
