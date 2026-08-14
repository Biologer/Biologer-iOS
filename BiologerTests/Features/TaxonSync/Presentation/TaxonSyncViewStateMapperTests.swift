import XCTest
@testable import Biologer

final class TaxonSyncViewStateMapperTests: XCTestCase {
    private let sut = TaxonSyncViewStateMapper()

    func test_idleEmptyCatalog_offersInitialDownloadAndBlocksContinue() {
        let viewState = sut.map(
            state: TaxonSyncState(
                catalogStatus: makeStatus(availability: .empty),
                operation: .idle
            ),
            actionFailure: nil,
            isPerformingPrimaryAction: false
        )

        XCTAssertEqual(viewState.primaryAction?.action, .start)
        XCTAssertFalse(viewState.canContinue)
    }

    func test_waitingForNetworkWithInitialCatalog_offersResumeAndAllowsContinue() {
        let state = TaxonSyncState(
            catalogStatus: makeStatus(availability: .initialCatalogLoaded),
            operation: .waitingForNetwork(nil)
        )

        let viewState = sut.map(
            state: state,
            actionFailure: nil,
            isPerformingPrimaryAction: false
        )

        XCTAssertEqual(viewState.primaryAction?.action, .resume)
        XCTAssertTrue(viewState.canContinue)
    }

    func test_workingDownload_exposesProgressAndPause() {
        let progress = TaxonSyncProgress(
            completedPages: 1,
            totalPages: 2,
            importedTaxaCount: 100,
            totalTaxaCount: 200
        )
        let state = TaxonSyncState(
            catalogStatus: makeStatus(availability: .ready),
            operation: .working(phase: .downloading, progress: progress)
        )

        let viewState = sut.map(
            state: state,
            actionFailure: nil,
            isPerformingPrimaryAction: false
        )

        XCTAssertEqual(viewState.progress, progress)
        XCTAssertTrue(viewState.canPause)
        XCTAssertTrue(viewState.canContinue)
    }

    func test_runningPrimaryAction_disablesItsButton() {
        let viewState = sut.map(
            state: TaxonSyncState(
                catalogStatus: makeStatus(availability: .ready),
                operation: .idle
            ),
            actionFailure: nil,
            isPerformingPrimaryAction: true
        )

        XCTAssertEqual(viewState.primaryAction?.action, .check)
        XCTAssertFalse(viewState.primaryAction?.isEnabled ?? true)
    }

    private func makeStatus(
        availability: TaxonCatalogAvailability
    ) -> TaxonCatalogStatus {
        TaxonCatalogStatus(
            scope: TaxonCatalogScope(environmentHost: "api.biologer.org"),
            availability: availability,
            localTaxaCount: availability == .empty ? 0 : 100,
            lastSuccessfulSyncTimestamp: availability == .ready ? 1 : nil
        )
    }
}
