import XCTest
@testable import Biologer

final class RegistrationInputValidatorTests: XCTestCase {
    private var sut: DefaultRegistrationInputValidator!

    override func setUp() {
        super.setUp()
        sut = DefaultRegistrationInputValidator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_validatePersonalInfo_returnsPersonalInfoForValidInput() throws {
        let personalInfo = try sut.validatePersonalInfo(
            firstName: "Nikola",
            lastName: "Popovic",
            institution: "Biologer"
        )

        XCTAssertEqual(personalInfo.firstName, "Nikola")
        XCTAssertEqual(personalInfo.lastName, "Popovic")
        XCTAssertEqual(personalInfo.institution, "Biologer")
    }

    func test_validatePersonalInfo_throwsEmptyUsernameForBlankFirstName() {
        XCTAssertThrowsError(
            try sut.validatePersonalInfo(
                firstName: "   ",
                lastName: "Popovic",
                institution: ""
            )
        ) { error in
            XCTAssertEqual(error as? RegisterUserValidationError, .emptyUsername)
        }
    }

    func test_validatePersonalInfo_throwsEmptyLastNameForBlankLastName() {
        XCTAssertThrowsError(
            try sut.validatePersonalInfo(
                firstName: "Nikola",
                lastName: "\n",
                institution: ""
            )
        ) { error in
            XCTAssertEqual(error as? RegisterUserValidationError, .emptyLastName)
        }
    }

    func test_validateCredentials_returnsCredentialsForValidInput() throws {
        let credentials = try sut.validateCredentials(
            email: "nikola@example.com",
            password: "Password1",
            repeatedPassword: "Password1"
        )

        XCTAssertEqual(credentials.email, "nikola@example.com")
        XCTAssertEqual(credentials.password, "Password1")
    }

    func test_validateCredentials_throwsInvalidEmailForMalformedEmail() {
        XCTAssertThrowsError(
            try sut.validateCredentials(
                email: "invalid",
                password: "Password1",
                repeatedPassword: "Password1"
            )
        ) { error in
            XCTAssertEqual(error as? RegisterUserValidationError, .invalidEmail)
        }
    }

    func test_validateCredentials_throwsInvalidPasswordForWeakPassword() {
        XCTAssertThrowsError(
            try sut.validateCredentials(
                email: "nikola@example.com",
                password: "password",
                repeatedPassword: "password"
            )
        ) { error in
            XCTAssertEqual(error as? RegisterUserValidationError, .invalidPassword)
        }
    }

    func test_validateCredentials_throwsPasswordsDoNotMatch() {
        XCTAssertThrowsError(
            try sut.validateCredentials(
                email: "nikola@example.com",
                password: "Password1",
                repeatedPassword: "Password2"
            )
        ) { error in
            XCTAssertEqual(error as? RegisterUserValidationError, .passwordsDoNotMatch)
        }
    }
}
