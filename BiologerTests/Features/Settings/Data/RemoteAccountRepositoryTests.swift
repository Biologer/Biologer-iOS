import XCTest
@testable import Biologer

final class RemoteAccountRepositoryTests: XCTestCase {
    func test_loadCurrentUser_whenResponseIsValid_mapsProfileToDomainUser() async throws {
        // Given
        let client = AccountAPIClientStub(response: makeProfileResponse())
        let sut = RemoteAccountRepository(
            client: client,
            environmentStorage: AccountEnvironmentStorageStub(environment: makeEnvironment())
        )

        // When
        let user = try await sut.loadCurrentUser()

        // Then
        XCTAssertEqual(user.id, 42)
        XCTAssertEqual(user.firstName, "Nikola")
        XCTAssertEqual(user.lastName, "Popovic")
        XCTAssertEqual(user.email, "nikola@example.com")
        XCTAssertEqual(user.fullName, "Nikola Popovic")
        XCTAssertTrue(user.isVerified)
        XCTAssertEqual(user.settings.dataLicense, 10)
        XCTAssertEqual(user.settings.imageLicense, 20)
        XCTAssertEqual(user.settings.language, "sr-Latn")
        XCTAssertEqual((client.receivedEndpoint as? GetProfileEndpoint)?.host, "api.biologer.org")
    }

    func test_loadCurrentUser_whenEnvironmentIsMissing_throwsEnvironmentErrorWithoutRequest() async {
        // Given
        let client = AccountAPIClientStub(response: makeProfileResponse())
        let sut = RemoteAccountRepository(
            client: client,
            environmentStorage: AccountEnvironmentStorageStub(environment: nil)
        )

        // When
        do {
            _ = try await sut.loadCurrentUser()
            XCTFail("Expected environment error.")
        } catch {
            // Then
            XCTAssertEqual(error.description, ErrorConstant.environmentNotSelected)
            XCTAssertNil(client.receivedEndpoint)
        }
    }

    func test_deleteCurrentUser_whenRequested_sendsDeleteEndpointWithSelectedOption() async throws {
        // Given
        let client = AccountAPIClientStub(response: EmptyAPIResponse())
        let sut = RemoteAccountRepository(
            client: client,
            environmentStorage: AccountEnvironmentStorageStub(environment: makeEnvironment())
        )

        // When
        try await sut.deleteCurrentUser(userID: 42, deleteObservations: true)

        // Then
        let endpoint = try XCTUnwrap(client.receivedEndpoint as? DeleteAccountEndpoint)
        XCTAssertEqual(endpoint.host, "api.biologer.org")
        XCTAssertEqual(endpoint.path, "\(APIConstants.deleteUserPath)/42")
        XCTAssertEqual(endpoint.method, .delete)
        XCTAssertEqual(
            endpoint.queryItems,
            [URLQueryItem(name: "delete_observations", value: "1")]
        )
    }

    private func makeProfileResponse() -> UserDataResponse {
        UserDataResponse(
            data: UserDataResponse.UserResponse(
                id: 42,
                first_name: "Nikola",
                last_name: "Popovic",
                email: "nikola@example.com",
                full_name: "Nikola Popovic",
                is_verified: true,
                settings: UserDataResponse.UserResponse.Settings(
                    data_license: 10,
                    image_license: 20,
                    language: "sr-Latn"
                )
            )
        )
    }

    private func makeEnvironment() -> Biologer.Environment {
        Biologer.Environment(
            host: "api.biologer.org",
            path: "",
            clientSecret: "secret",
            cliendId: "client"
        )
    }
}

private final class AccountAPIClientStub: APIClientProtocol {
    private let response: Any
    private(set) var receivedEndpoint: Any?

    init(response: Any) {
        self.response = response
    }

    func send<Endpoint: APIEndpoint>(_ endpoint: Endpoint) async throws -> Endpoint.Response {
        receivedEndpoint = endpoint
        return response as! Endpoint.Response
    }
}

private final class AccountEnvironmentStorageStub: EnvironmentStorage {
    private let environment: Biologer.Environment?

    init(environment: Biologer.Environment?) {
        self.environment = environment
    }

    func getEnvironment() -> Biologer.Environment? {
        environment
    }

    func saveEnvironment(env: Biologer.Environment) {}
    func delete() {}
}
