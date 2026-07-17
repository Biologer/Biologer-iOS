import XCTest
@testable import Biologer

final class SetupUseCaseTests: XCTestCase {
    private var settingsStorage: SetupSettingsStorageSpy!
    private var dataLicenseStorage: SetupLicenseStorageSpy!
    private var imageLicenseStorage: SetupLicenseStorageSpy!
    private var taxonPaginationStorage: SetupTaxonPaginationInfoStorageSpy!
    private var taxonLocalDataStore: SetupTaxonLocalDataStoreSpy!
    private var sut: DefaultSetupUseCase!

    override func setUp() {
        super.setUp()
        settingsStorage = SetupSettingsStorageSpy(settings: Settings())
        dataLicenseStorage = SetupLicenseStorageSpy()
        imageLicenseStorage = SetupLicenseStorageSpy()
        taxonPaginationStorage = SetupTaxonPaginationInfoStorageSpy()
        taxonLocalDataStore = SetupTaxonLocalDataStoreSpy()
        sut = DefaultSetupUseCase(
            settingsStorage: settingsStorage,
            dataLicenseStorage: dataLicenseStorage,
            imageLicenseStorage: imageLicenseStorage,
            taxonPaginationStorage: taxonPaginationStorage,
            taxonLocalDataStore: taxonLocalDataStore
        )
    }

    override func tearDown() {
        sut = nil
        taxonLocalDataStore = nil
        taxonPaginationStorage = nil
        imageLicenseStorage = nil
        dataLicenseStorage = nil
        settingsStorage = nil
        super.tearDown()
    }

    func test_toggleSetting_updatesAndSavesSettings() {
        sut.toggleSetting(for: .englishNames)

        XCTAssertTrue(settingsStorage.savedSettings?.alwaysEnglishName == true)
    }

    func test_saveProjectName_updatesAndSavesSettings() {
        sut.saveProjectName("Field project")

        XCTAssertEqual(settingsStorage.savedSettings?.projectName, "Field project")
    }

    func test_selectAutoDownloadTaxon_updatesAndSavesSettings() {
        sut.selectAutoDownloadTaxon(.onlyWiFi)

        XCTAssertEqual(settingsStorage.savedSettings?.selectedAutoDownloadTaxon.type, .onlyWiFi)
    }

    func test_saveDataLicense_delegatesToStorage() {
        let license = makeLicense(id: 10, type: .data)

        sut.saveDataLicense(license)

        XCTAssertEqual(dataLicenseStorage.savedLicense, license)
    }

    func test_saveImageLicense_delegatesToStorage() {
        let license = makeLicense(id: 20, type: .image)

        sut.saveImageLicense(license)

        XCTAssertEqual(imageLicenseStorage.savedLicense, license)
    }

    func test_resetDownloadedTaxa_deletesTaxaAndPagination() {
        sut.resetDownloadedTaxa()

        XCTAssertTrue(taxonLocalDataStore.didDeleteTaxa)
        XCTAssertTrue(taxonPaginationStorage.didDelete)
    }

    private func makeLicense(id: Int, type: CheckMarkItemType) -> CheckMarkItem {
        CheckMarkItem(
            id: id,
            title: "License",
            placeholder: "Placeholder",
            type: type,
            isSelected: true
        )
    }
}

private final class SetupSettingsStorageSpy: SettingsStorage {
    var settings: Settings?
    private(set) var savedSettings: Settings?
    private(set) var didDelete = false

    init(settings: Settings?) {
        self.settings = settings
    }

    func getSettings() -> Settings? {
        settings
    }

    func saveSettings(settings: Settings) {
        savedSettings = settings
        self.settings = settings
    }

    func delete() {
        didDelete = true
        settings = nil
    }
}

private final class SetupLicenseStorageSpy: LicenseStorage {
    var license: CheckMarkItem?
    private(set) var savedLicense: CheckMarkItem?
    private(set) var didDelete = false

    func getLicense() -> CheckMarkItem? {
        license
    }

    func saveLicense(license: CheckMarkItem) {
        savedLicense = license
        self.license = license
    }

    func delete() {
        didDelete = true
        license = nil
    }
}

private final class SetupTaxonPaginationInfoStorageSpy: TaxonsPaginationInfoStorage {
    private(set) var didDelete = false

    func getPaginationInfo() -> TaxonsPaginationInfo? {
        nil
    }

    func getLastReadFromFile() -> Int64? {
        nil
    }

    func savePagination(paginationInfo: TaxonsPaginationInfo) {}

    func saveLastReadFromFile(_ date: Int64) {}

    func delete() {
        didDelete = true
    }
}

private final class SetupTaxonLocalDataStoreSpy: SetupTaxonLocalDataStore {
    var hasTaxaResult = false
    private(set) var didDeleteTaxa = false

    func hasTaxa() -> Bool {
        hasTaxaResult
    }

    func deleteTaxa() {
        didDeleteTaxa = true
    }
}
