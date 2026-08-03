import UIKit

@MainActor
final class MainTabCoordinator: MainCoordinating {
    typealias MainViewControllerFactory = (
        _ onDownloadTaxa: @escaping Observer<Void>,
        _ onLogout: @escaping Observer<Void>,
        _ onDeleteAccount: @escaping Observer<Bool>
    ) -> UIViewController

    private let navigationController: UINavigationController
    private let makeMainViewController: MainViewControllerFactory

    var rootViewController: UIViewController {
        navigationController
    }

    var primaryNavigationController: UINavigationController {
        navigationController
    }

    var onLogout: Observer<Void>?
    var onStartDownloadTaxa: Observer<UINavigationController>?
    var onDeleteAccount: Observer<Bool>?

    init(
        navigationController: UINavigationController,
        makeMainViewController: @escaping MainViewControllerFactory
    ) {
        self.navigationController = navigationController
        self.makeMainViewController = makeMainViewController
    }

    func start() {
        let viewController = makeMainViewController(
            { [weak self] _ in
                guard let self else { return }
                self.onStartDownloadTaxa?(self.navigationController)
            },
            { [weak self] _ in
                self?.onLogout?(())
            },
            { [weak self] deleteObservations in
                self?.onDeleteAccount?(deleteObservations)
            }
        )
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([viewController], animated: false)
    }
}
