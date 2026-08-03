import Foundation

protocol AuthorizationCoordinating: AnyObject {
    var onAuthorizationSuccess: Observer<Void>? { get set }

    func start(shouldPresentIntroScreens: Bool)
    func restart()
}
