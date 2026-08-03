import UIKit

@MainActor
protocol MainCoordinating: AnyObject {
    var rootViewController: UIViewController { get }
    var primaryNavigationController: UINavigationController { get }
    var onLogout: Observer<Void>? { get set }
    var onStartDownloadTaxa: Observer<UINavigationController>? { get set }
    var onDeleteAccount: Observer<Bool>? { get set }

    func start()
}

protocol LegacyMainRouting: AnyObject {
    var onLogout: Observer<Void>? { get set }
    var onStartDownloadTaxon: Observer<Void>? { get set }

    func start()
}

protocol TaxonRouting: AnyObject {
    func start()
    func startNewFinding()
}

extension SideMenuRouterRouter: LegacyMainRouting {}
extension TaxonRouter: TaxonRouting {}
