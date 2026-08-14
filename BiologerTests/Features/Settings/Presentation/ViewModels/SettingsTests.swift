import XCTest
@testable import Biologer

@MainActor
final class SettingsTests: XCTestCase {
    func test_settings_whenDecodingLegacyPayload_preservesActivePreferences() throws {
        // Given
        let data = try XCTUnwrap(
            """
            {
              "chooseSpeciesGroup": true,
              "alwaysEnglishName": true,
              "setAdultByDefault": true,
              "advanceObservationEntry": true,
              "projectName": "Legacy project",
              "selectedAutoDownloadTaxon": {
                "type": "onlyWiFi",
                "isSelected": true
              },
              "autoDownloadTaxon": [
                {
                  "type": "onlyWiFi",
                  "isSelected": true
                }
              ]
            }
            """.data(using: .utf8)
        )

        // When
        let sut = try JSONDecoder().decode(Settings.self, from: data)

        // Then
        XCTAssertTrue(sut.alwaysEnglishName)
        XCTAssertTrue(sut.setAdultByDefault)
        XCTAssertEqual(sut.projectName, "Legacy project")
        XCTAssertEqual(sut.selectedAutoDownloadTaxon.type, .onlyWiFi)
    }

    func test_user_whenDecodingLegacySettingsPayload_preservesActiveValues() throws {
        // Given
        let data = try XCTUnwrap(
            """
            {
              "id": 42,
              "firstName": "Nikola",
              "lastName": "Popovic",
              "email": "nikola@example.com",
              "fullName": "Nikola Popovic",
              "isVerified": true,
              "settings": {
                "dataLicense": 10,
                "imageLicense": 20,
                "language": "sr-Latn",
                "projectName": "Legacy project"
              }
            }
            """.data(using: .utf8)
        )

        // When
        let sut = try JSONDecoder().decode(User.self, from: data)

        // Then
        XCTAssertEqual(sut.id, 42)
        XCTAssertEqual(sut.settings.dataLicense, 10)
        XCTAssertEqual(sut.settings.imageLicense, 20)
        XCTAssertEqual(sut.settings.language, "sr-Latn")
    }

    func test_licenseStorage_whenSavingLicense_returnsPersistedLicense() throws {
        // Given
        let suiteName = "UserDefaultsLicenseStorageTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let license = try XCTUnwrap(CheckMarkItemMapper.getDataLicense().last)
        let sut = UserDefaultsLicenseStorage(
            key: "license.test.key",
            defaults: defaults
        )

        // When
        sut.saveLicense(license: license)

        // Then
        XCTAssertEqual(sut.getLicense(), license)
    }

    func test_preferencesUseCaseUpdatesSelectedToggle() {
        let repository = SettingsPreferencesRepositorySpy()
        let sut = DefaultSettingsPreferencesUseCase(repository: repository)

        sut.set(true, for: .englishNames)

        XCTAssertEqual(repository.savedPreferences?.alwaysUseEnglishNames, true)
        XCTAssertEqual(repository.savedPreferences?.defaultsToAdult, false)
    }

    func test_preferencesUseCaseSavesProjectName() {
        let repository = SettingsPreferencesRepositorySpy()
        let sut = DefaultSettingsPreferencesUseCase(repository: repository)

        sut.saveProjectName("Field project")

        XCTAssertEqual(repository.savedPreferences?.projectName, "Field project")
    }

    func test_projectNameViewModelSave_normalizesNameBeforeSaving() {
        let useCase = SettingsPreferencesUseCaseSpy()
        let sut = ProjectNameSettingsViewModel(useCase: useCase)
        sut.projectName = "  Field project\n"

        sut.save()

        XCTAssertEqual(sut.projectName, "Field project")
        XCTAssertEqual(useCase.savedProjectName, "Field project")
    }

    func test_preferencesUseCaseSavesAutomaticDownloadSelection() {
        let repository = SettingsPreferencesRepositorySpy()
        let sut = DefaultSettingsPreferencesUseCase(repository: repository)

        sut.selectAutomaticTaxonDownload(.onlyWiFi)

        XCTAssertEqual(repository.savedPreferences?.automaticTaxonDownload, .onlyWiFi)
    }

    func test_licenseUseCaseDelegatesSelectionToRepository() {
        let repository = SettingsLicenseRepositorySpy()
        let option = SettingsLicenseOption(id: 20, title: "License", details: "Details")
        let sut = DefaultSettingsLicenseUseCase(repository: repository)

        sut.select(option, for: .image)

        XCTAssertEqual(repository.savedOption, option)
        XCTAssertEqual(repository.savedKind, .image)
    }

    func test_taxonDataUseCaseResetsRepository() {
        let repository = DownloadedTaxaRepositorySpy()
        let sut = DefaultSettingsTaxonDataUseCase(repository: repository)

        sut.resetDownloadedTaxa()

        XCTAssertTrue(repository.didReset)
    }

    func test_storedPreferencesRepositoryMapsAndPersistsDomainValues() {
        let storage = SettingsStorageSpy(settings: Settings())
        let sut = StoredSettingsPreferencesRepository(storage: storage)
        let preferences = SettingsPreferences(
            alwaysUseEnglishNames: true,
            defaultsToAdult: true,
            projectName: "Field project",
            automaticTaxonDownload: .onlyWiFi
        )

        sut.save(preferences)

        XCTAssertEqual(storage.savedSettings?.alwaysEnglishName, true)
        XCTAssertEqual(storage.savedSettings?.setAdultByDefault, true)
        XCTAssertEqual(storage.savedSettings?.projectName, "Field project")
        XCTAssertEqual(storage.savedSettings?.selectedAutoDownloadTaxon.type, .onlyWiFi)
    }

    func test_storedLicenseRepositoryPersistsSelectedImageLicense() throws {
        let dataStorage = SettingsLicenseStorageSpy()
        let imageStorage = SettingsLicenseStorageSpy()
        let sut = StoredSettingsLicenseRepository(
            dataLicenseStorage: dataStorage,
            imageLicenseStorage: imageStorage
        )
        let option = try XCTUnwrap(sut.options(for: .image).last)

        sut.save(option, for: .image)

        XCTAssertNil(dataStorage.savedLicense)
        XCTAssertEqual(imageStorage.savedLicense?.id, option.id)
    }

    func test_settingsViewModelShowsEmptyAlertWithoutDeletingTaxa() {
        let preferencesUseCase = SettingsPreferencesUseCaseSpy()
        let taxonDataUseCase = SettingsTaxonDataUseCaseSpy()
        taxonDataUseCase.hasDownloadedTaxaResult = false
        let sut = SettingsScreenViewModel(
            preferencesUseCase: preferencesUseCase,
            taxonDataUseCase: taxonDataUseCase
        )

        sut.requestTaxaReset()

        XCTAssertEqual(sut.resetAlert?.id, SettingsResetAlert.noDownloadedTaxa.id)
        XCTAssertFalse(taxonDataUseCase.didReset)
    }

    func test_settingsViewModelConfirmsTaxaReset() {
        let preferencesUseCase = SettingsPreferencesUseCaseSpy()
        let taxonDataUseCase = SettingsTaxonDataUseCaseSpy()
        taxonDataUseCase.hasDownloadedTaxaResult = true
        let sut = SettingsScreenViewModel(
            preferencesUseCase: preferencesUseCase,
            taxonDataUseCase: taxonDataUseCase
        )

        sut.requestTaxaReset()
        sut.confirmTaxaReset()

        XCTAssertTrue(taxonDataUseCase.didReset)
        XCTAssertEqual(sut.resetAlert?.id, SettingsResetAlert.completed.id)
    }

    func test_accountViewModel_logoutWhenRequested_invokesLogoutUseCase() async {
        // Given
        let logoutUseCase = SettingsLogoutUseCaseSpy()
        let sut = makeAccountViewModel(logoutUseCase: logoutUseCase)

        // When
        await sut.logout()

        // Then
        XCTAssertEqual(logoutUseCase.logoutCallCount, 1)
    }

    func test_accountViewModel_deleteAccountWhenRequestSucceeds_deletesSelectedDataAndLogsOut() async {
        // Given
        let accountUseCase = SettingsAccountUseCaseSpy()
        let logoutUseCase = SettingsLogoutUseCaseSpy()
        let sut = makeAccountViewModel(
            accountUseCase: accountUseCase,
            logoutUseCase: logoutUseCase
        )
        sut.shouldDeleteObservations = true

        // When
        await sut.deleteAccount()

        // Then
        XCTAssertEqual(accountUseCase.deleteRequests, [true])
        XCTAssertEqual(logoutUseCase.logoutCallCount, 1)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_accountViewModel_deleteAccountWhenRequestFails_publishesErrorWithoutLogout() async {
        // Given
        let accountUseCase = SettingsAccountUseCaseSpy()
        accountUseCase.deleteResult = .failure(
            SettingsDataFailure(message: "delete failed")
        )
        let logoutUseCase = SettingsLogoutUseCaseSpy()
        let sut = makeAccountViewModel(
            accountUseCase: accountUseCase,
            logoutUseCase: logoutUseCase
        )

        // When
        await sut.deleteAccount()

        // Then
        XCTAssertEqual(accountUseCase.deleteRequests, [false])
        XCTAssertEqual(logoutUseCase.logoutCallCount, 0)
        XCTAssertEqual(sut.errorMessage, "delete failed")
        XCTAssertFalse(sut.isLoading)
    }

    func test_accountViewModel_dismissErrorWhenErrorExists_clearsPublishedError() async {
        // Given
        let accountUseCase = SettingsAccountUseCaseSpy()
        accountUseCase.deleteResult = .failure(
            SettingsDataFailure(message: "delete failed")
        )
        let sut = makeAccountViewModel(accountUseCase: accountUseCase)
        await sut.deleteAccount()

        // When
        sut.dismissError()

        // Then
        XCTAssertNil(sut.errorMessage)
    }

    func test_aboutViewModel_whenEnvironmentUsesHTTPS_exposesExternalURL() {
        // Given
        let sut = SettingsAboutViewModel(
            environment: "https://api.biologer.org",
            version: "3.0.4"
        )

        // When
        let url = sut.environmentURL

        // Then
        XCTAssertEqual(url?.absoluteString, "https://api.biologer.org")
    }

    func test_aboutViewModel_whenEnvironmentHasUnsupportedScheme_doesNotExposeURL() {
        // Given
        let sut = SettingsAboutViewModel(
            environment: "javascript:alert(1)",
            version: "3.0.4"
        )

        // When
        let url = sut.environmentURL

        // Then
        XCTAssertNil(url)
    }

    private func makeAccountViewModel(
        accountUseCase: UserAccountUseCase = SettingsAccountUseCaseSpy(),
        logoutUseCase: LogoutUseCase = SettingsLogoutUseCaseSpy()
    ) -> SettingsAccountViewModel {
        SettingsAccountViewModel(
            context: SettingsAccountContext(
                email: "user@example.com",
                username: "Biologer User",
                environment: "https://api.biologer.org"
            ),
            accountUseCase: accountUseCase,
            logoutUseCase: logoutUseCase
        )
    }
}

private final class SettingsAccountUseCaseSpy: UserAccountUseCase {
    var deleteResult: Result<Void, SettingsDataFailure> = .success(())
    private(set) var deleteRequests: [Bool] = []

    func loadCurrentUser() async throws(SettingsDataFailure) -> User {
        fatalError("Not used by SettingsAccountViewModel.")
    }

    func deleteCurrentUser(deleteObservations: Bool) async throws(SettingsDataFailure) {
        deleteRequests.append(deleteObservations)
        try deleteResult.get()
    }
}

private final class SettingsLogoutUseCaseSpy: LogoutUseCase {
    private(set) var logoutCallCount = 0

    func logout() async {
        logoutCallCount += 1
    }
}

private final class SettingsPreferencesRepositorySpy: SettingsPreferencesRepository {
    var storedPreferences = SettingsPreferences(
        alwaysUseEnglishNames: false,
        defaultsToAdult: false,
        projectName: "",
        automaticTaxonDownload: .alwaysAskUser
    )
    private(set) var savedPreferences: SettingsPreferences?

    func load() -> SettingsPreferences {
        storedPreferences
    }

    func save(_ preferences: SettingsPreferences) {
        storedPreferences = preferences
        savedPreferences = preferences
    }
}

private final class SettingsLicenseRepositorySpy: SettingsLicenseRepository {
    let option = SettingsLicenseOption(id: 10, title: "License", details: "Details")
    private(set) var savedOption: SettingsLicenseOption?
    private(set) var savedKind: SettingsLicenseKind?

    func options(for kind: SettingsLicenseKind) -> [SettingsLicenseOption] {
        [option]
    }

    func selectedOption(for kind: SettingsLicenseKind) -> SettingsLicenseOption {
        option
    }

    func save(_ option: SettingsLicenseOption, for kind: SettingsLicenseKind) {
        savedOption = option
        savedKind = kind
    }
}

private final class DownloadedTaxaRepositorySpy: DownloadedTaxaRepository {
    var hasDownloadedTaxaResult = false
    private(set) var didReset = false

    func hasDownloadedTaxa() -> Bool {
        hasDownloadedTaxaResult
    }

    func resetDownloadedTaxa() {
        didReset = true
    }
}

private final class SettingsPreferencesUseCaseSpy: SettingsPreferencesUseCase {
    var storedPreferences = SettingsPreferences(
        alwaysUseEnglishNames: false,
        defaultsToAdult: false,
        projectName: "",
        automaticTaxonDownload: .alwaysAskUser
    )
    private(set) var savedProjectName: String?

    func preferences() -> SettingsPreferences {
        storedPreferences
    }

    func set(_ isEnabled: Bool, for toggle: SettingsToggle) {}
    func saveProjectName(_ projectName: String) {
        savedProjectName = projectName
    }
    func selectAutomaticTaxonDownload(_ option: AutomaticTaxonDownload) {}
}

private final class SettingsTaxonDataUseCaseSpy: SettingsTaxonDataUseCase {
    var hasDownloadedTaxaResult = false
    private(set) var didReset = false

    func hasDownloadedTaxa() -> Bool {
        hasDownloadedTaxaResult
    }

    func resetDownloadedTaxa() {
        didReset = true
    }
}

private final class SettingsStorageSpy: SettingsStorage {
    private var settings: Settings?
    private(set) var savedSettings: Settings?

    init(settings: Settings?) {
        self.settings = settings
    }

    func getSettings() -> Settings? {
        settings
    }

    func saveSettings(settings: Settings) {
        self.settings = settings
        savedSettings = settings
    }
}

private final class SettingsLicenseStorageSpy: LicenseStorage {
    private var license: CheckMarkItem?
    private(set) var savedLicense: CheckMarkItem?

    func getLicense() -> CheckMarkItem? {
        license
    }

    func saveLicense(license: CheckMarkItem) {
        self.license = license
        savedLicense = license
    }
}
