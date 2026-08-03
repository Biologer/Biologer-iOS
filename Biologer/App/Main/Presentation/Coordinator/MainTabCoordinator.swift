import UIKit

final class MainTabCoordinator: MainCoordinating {
    typealias SettingsViewControllerFactory = (
        _ onDownloadTaxa: @escaping Observer<Void>,
        _ onLogout: @escaping Observer<Void>,
        _ onDeleteAccount: @escaping Observer<Bool>
    ) -> UIViewController

    private let tabBarController: MainTabBarController
    private let findingsNavigationController: UINavigationController
    private let settingsNavigationController: UINavigationController
    private let taxonRouter: TaxonRouting
    private let makeSettingsViewController: SettingsViewControllerFactory

    var rootViewController: UIViewController {
        tabBarController
    }

    var primaryNavigationController: UINavigationController {
        findingsNavigationController
    }

    var onLogout: Observer<Void>?
    var onStartDownloadTaxa: Observer<UINavigationController>?
    var onDeleteAccount: Observer<Bool>?

    init(
        tabBarController: MainTabBarController = MainTabBarController(),
        findingsNavigationController: UINavigationController,
        settingsNavigationController: UINavigationController,
        taxonRouter: TaxonRouting,
        makeSettingsViewController: @escaping SettingsViewControllerFactory
    ) {
        self.tabBarController = tabBarController
        self.findingsNavigationController = findingsNavigationController
        self.settingsNavigationController = settingsNavigationController
        self.taxonRouter = taxonRouter
        self.makeSettingsViewController = makeSettingsViewController
    }

    func start() {
        taxonRouter.start()

        let settingsViewController = makeSettingsViewController(
            { [weak self] _ in
                guard let self else { return }
                self.onStartDownloadTaxa?(self.settingsNavigationController)
            },
            { [weak self] _ in
                self?.onLogout?(())
            },
            { [weak self] deleteObservations in
                self?.onDeleteAccount?(deleteObservations)
            }
        )
        settingsNavigationController.setViewControllers(
            [settingsViewController],
            animated: false
        )

        tabBarController.onAddTapped = { [weak self] _ in
            guard let self else { return }
            self.tabBarController.selectedIndex = 0
            self.taxonRouter.startNewFinding()
        }
        tabBarController.setTabs(
            findings: findingsNavigationController,
            settings: settingsNavigationController
        )
    }
}
