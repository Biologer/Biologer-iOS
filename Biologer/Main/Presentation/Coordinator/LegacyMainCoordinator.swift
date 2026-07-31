import UIKit

final class LegacyMainCoordinator: MainCoordinating {
    private let navigationController: UINavigationController
    private let router: LegacyMainRouting

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
        router: LegacyMainRouting
    ) {
        self.navigationController = navigationController
        self.router = router
    }

    func start() {
        router.onLogout = { [weak self] _ in
            self?.onLogout?(())
        }
        router.onStartDownloadTaxon = { [weak self] _ in
            guard let self else { return }
            self.onStartDownloadTaxa?(self.navigationController)
        }
        router.start()
    }
}
