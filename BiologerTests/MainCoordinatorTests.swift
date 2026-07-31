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

    func test_tabCoordinatorStartsThreeTabsAndSettingsFlow() {
        let context = makeTabCoordinator()

        context.coordinator.start()

        XCTAssertTrue(context.taxonRouter.didStart)
        XCTAssertEqual(context.tabBarController.viewControllers?.count, 3)
        XCTAssertTrue(context.settingsNavigationController.topViewController === context.settingsViewController)
        XCTAssertEqual(context.tabBarController.selectedIndex, 0)
    }

    func test_middleTabStartsNewFindingWithoutChangingSelection() throws {
        let context = makeTabCoordinator()
        context.coordinator.start()
        let addAction = try XCTUnwrap(context.tabBarController.viewControllers?[1])

        let shouldSelect = context.tabBarController.tabBarController(
            context.tabBarController,
            shouldSelect: addAction
        )

        XCTAssertFalse(shouldSelect)
        XCTAssertTrue(context.taxonRouter.didStartNewFinding)
        XCTAssertEqual(context.tabBarController.selectedIndex, 0)
    }

    func test_settingsActionsAreForwardedByTabCoordinator() {
        let context = makeTabCoordinator()
        var didRequestDownload = false
        var didRequestLogout = false
        var deleteObservations: Bool?
        context.coordinator.onStartDownloadTaxa = { navigationController in
            didRequestDownload = navigationController === context.settingsNavigationController
        }
        context.coordinator.onLogout = { _ in
            didRequestLogout = true
        }
        context.coordinator.onDeleteAccount = { value in
            deleteObservations = value
        }
        context.coordinator.start()

        context.settingsActions.onDownloadTaxa?(())
        context.settingsActions.onLogout?(())
        context.settingsActions.onDeleteAccount?(true)

        XCTAssertTrue(didRequestDownload)
        XCTAssertTrue(didRequestLogout)
        XCTAssertEqual(deleteObservations, true)
    }

    private func makeTabCoordinator() -> MainTabCoordinatorTestContext {
        let tabBarController = MainTabBarController()
        tabBarController.loadViewIfNeeded()
        let findingsNavigationController = UINavigationController()
        let settingsNavigationController = UINavigationController()
        let taxonRouter = TaxonRoutingSpy()
        let settingsViewController = UIViewController()
        let settingsActions = SettingsActionsSpy()
        let coordinator = MainTabCoordinator(
            tabBarController: tabBarController,
            findingsNavigationController: findingsNavigationController,
            settingsNavigationController: settingsNavigationController,
            taxonRouter: taxonRouter,
            makeSettingsViewController: { onDownloadTaxa, onLogout, onDeleteAccount in
                settingsActions.onDownloadTaxa = onDownloadTaxa
                settingsActions.onLogout = onLogout
                settingsActions.onDeleteAccount = onDeleteAccount
                return settingsViewController
            }
        )
        return MainTabCoordinatorTestContext(
            coordinator: coordinator,
            tabBarController: tabBarController,
            settingsNavigationController: settingsNavigationController,
            taxonRouter: taxonRouter,
            settingsViewController: settingsViewController,
            settingsActions: settingsActions
        )
    }
}

private struct MainTabCoordinatorTestContext {
    let coordinator: MainTabCoordinator
    let tabBarController: MainTabBarController
    let settingsNavigationController: UINavigationController
    let taxonRouter: TaxonRoutingSpy
    let settingsViewController: UIViewController
    let settingsActions: SettingsActionsSpy
}

private final class MainCoordinatorStub: MainCoordinating {
    let rootViewController = UIViewController()
    let primaryNavigationController = UINavigationController()
    var onLogout: Observer<Void>?
    var onStartDownloadTaxa: Observer<UINavigationController>?
    var onDeleteAccount: Observer<Bool>?

    func start() {}
}

private final class TaxonRoutingSpy: TaxonRouting {
    private(set) var didStart = false
    private(set) var didStartNewFinding = false

    func start() {
        didStart = true
    }

    func startNewFinding() {
        didStartNewFinding = true
    }
}

private final class SettingsActionsSpy {
    var onDownloadTaxa: Observer<Void>?
    var onLogout: Observer<Void>?
    var onDeleteAccount: Observer<Bool>?
}
