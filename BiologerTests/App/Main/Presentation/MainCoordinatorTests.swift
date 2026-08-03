import UIKit
import XCTest
@testable import Biologer

@MainActor
final class MainCoordinatorTests: XCTestCase {
    func test_builderSelectsLegacyCoordinatorForV1() {
        let legacy = MainCoordinatorStub()
        let tab = MainCoordinatorStub()
        let sut = MainCoordinatorBuilder(
            version: .v1,
            makeLegacyCoordinator: { legacy },
            makeTabCoordinator: { tab }
        )

        let coordinator = sut.makeCoordinator()

        XCTAssertTrue(coordinator === legacy)
    }

    func test_builderSelectsTabCoordinatorForV2() {
        let legacy = MainCoordinatorStub()
        let tab = MainCoordinatorStub()
        let sut = MainCoordinatorBuilder(
            version: .v2,
            makeLegacyCoordinator: { legacy },
            makeTabCoordinator: { tab }
        )

        let coordinator = sut.makeCoordinator()

        XCTAssertTrue(coordinator === tab)
    }

    func test_tabCoordinatorHostsSwiftUIMainSceneInNavigationBridge() {
        let context = makeTabCoordinator()

        context.coordinator.start()

        XCTAssertTrue(context.coordinator.rootViewController === context.navigationController)
        XCTAssertTrue(
            context.coordinator.primaryNavigationController
                === context.navigationController
        )
        XCTAssertTrue(
            context.navigationController.topViewController
                === context.mainViewController
        )
        XCTAssertTrue(context.navigationController.isNavigationBarHidden)
    }

    func test_tabCoordinatorForwardsLegacyAppActions() {
        let context = makeTabCoordinator()
        var downloadNavigationController: UINavigationController?
        var didRequestLogout = false
        var deleteObservations: Bool?
        context.coordinator.onStartDownloadTaxa = {
            downloadNavigationController = $0
        }
        context.coordinator.onLogout = { _ in
            didRequestLogout = true
        }
        context.coordinator.onDeleteAccount = {
            deleteObservations = $0
        }
        context.coordinator.start()

        context.actions.onDownloadTaxa?(())
        context.actions.onLogout?(())
        context.actions.onDeleteAccount?(true)

        XCTAssertTrue(downloadNavigationController === context.navigationController)
        XCTAssertTrue(didRequestLogout)
        XCTAssertEqual(deleteObservations, true)
    }

    private func makeTabCoordinator() -> MainTabCoordinatorTestContext {
        let navigationController = UINavigationController()
        let mainViewController = UIViewController()
        let actions = MainCoordinatorActionsSpy()
        let coordinator = MainTabCoordinator(
            navigationController: navigationController,
            makeMainViewController: { onDownloadTaxa, onLogout, onDeleteAccount in
                actions.onDownloadTaxa = onDownloadTaxa
                actions.onLogout = onLogout
                actions.onDeleteAccount = onDeleteAccount
                return mainViewController
            }
        )
        return MainTabCoordinatorTestContext(
            coordinator: coordinator,
            navigationController: navigationController,
            mainViewController: mainViewController,
            actions: actions
        )
    }
}

@MainActor
final class MainTabNavigationTests: XCTestCase {
    func test_initialStateShowsFindingsWithCreateEditorPrepared() {
        let context = makeSUT()

        XCTAssertEqual(context.sut.selectedTab, .findings)
        XCTAssertEqual(context.sut.editorMode, .create)
        XCTAssertNil(context.sut.pendingEditorMode)
    }

    func test_addFromFindingsSelectsExistingCreateEditor() {
        let context = makeSUT()
        let initialSessionID = context.sut.editorSessionID

        context.sut.openCreateEditor()

        XCTAssertEqual(context.sut.selectedTab, .editor)
        XCTAssertEqual(context.sut.editorMode, .create)
        XCTAssertEqual(context.sut.editorSessionID, initialSessionID)
    }

    func test_editFromFindingsSelectsFreshEditSession() {
        let context = makeSUT()
        let id = UUID()
        let initialSessionID = context.sut.editorSessionID

        context.sut.openEditEditor(id: id)

        XCTAssertEqual(context.sut.selectedTab, .editor)
        XCTAssertEqual(context.sut.editorMode, .edit(id))
        XCTAssertNotEqual(context.sut.editorSessionID, initialSessionID)
    }

    func test_unsavedEditorWaitsForConfirmationBeforeOpeningAnotherFinding() {
        let context = makeSUT()
        let id = UUID()
        let initialSessionID = context.sut.editorSessionID
        context.sut.updateEditorUnsavedChanges(true)

        context.sut.openEditEditor(id: id)

        XCTAssertEqual(context.sut.selectedTab, .editor)
        XCTAssertEqual(context.sut.editorMode, .create)
        XCTAssertEqual(context.sut.editorSessionID, initialSessionID)
        XCTAssertEqual(context.sut.pendingEditorMode, .edit(id))
    }

    func test_continuingEditorKeepsUnsavedSession() {
        let context = makeSUT()
        let initialSessionID = context.sut.editorSessionID
        context.sut.updateEditorUnsavedChanges(true)
        context.sut.openEditEditor(id: UUID())

        context.sut.continueEditing()

        XCTAssertEqual(context.sut.editorMode, .create)
        XCTAssertEqual(context.sut.editorSessionID, initialSessionID)
        XCTAssertNil(context.sut.pendingEditorMode)
    }

    func test_discardingChangesOpensPendingEditorSession() {
        let context = makeSUT()
        let id = UUID()
        let initialSessionID = context.sut.editorSessionID
        context.sut.updateEditorUnsavedChanges(true)
        context.sut.openEditEditor(id: id)

        context.sut.discardChangesAndOpenPendingEditor()

        XCTAssertEqual(context.sut.editorMode, .edit(id))
        XCTAssertNotEqual(context.sut.editorSessionID, initialSessionID)
        XCTAssertNil(context.sut.pendingEditorMode)
    }

    func test_savedFindingReloadsListAndPreparesFreshCreateSession() {
        let context = makeSUT()
        context.sut.openEditEditor(id: UUID())
        let editSessionID = context.sut.editorSessionID

        context.sut.didSaveFinding()

        XCTAssertEqual(context.findingsFlowController.reloadCallCount, 1)
        XCTAssertEqual(context.sut.selectedTab, .findings)
        XCTAssertEqual(context.sut.editorMode, .create)
        XCTAssertNotEqual(context.sut.editorSessionID, editSessionID)
    }

    private func makeSUT() -> MainTabNavigationTestContext {
        let findingsFlowController = FindingsFlowControllerSpy()
        return MainTabNavigationTestContext(
            sut: MainTabNavigation(
                findingsFlowController: findingsFlowController
            ),
            findingsFlowController: findingsFlowController
        )
    }
}

@MainActor
private struct MainTabCoordinatorTestContext {
    let coordinator: MainTabCoordinator
    let navigationController: UINavigationController
    let mainViewController: UIViewController
    let actions: MainCoordinatorActionsSpy
}

@MainActor
private struct MainTabNavigationTestContext {
    let sut: MainTabNavigation
    let findingsFlowController: FindingsFlowControllerSpy
}

@MainActor
private final class MainCoordinatorStub: MainCoordinating {
    let rootViewController = UIViewController()
    let primaryNavigationController = UINavigationController()
    var onLogout: Observer<Void>?
    var onStartDownloadTaxa: Observer<UINavigationController>?
    var onDeleteAccount: Observer<Bool>?

    func start() {}
}

@MainActor
private final class FindingsFlowControllerSpy: FindingsFlowControlling {
    private(set) var reloadCallCount = 0

    func showListAndReload() {
        reloadCallCount += 1
    }
}

private final class MainCoordinatorActionsSpy {
    var onDownloadTaxa: Observer<Void>?
    var onLogout: Observer<Void>?
    var onDeleteAccount: Observer<Bool>?
}
