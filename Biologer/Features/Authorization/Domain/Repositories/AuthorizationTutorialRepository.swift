import Foundation

protocol AuthorizationTutorialRepository {
    var wasPresented: Bool { get }
    func markPresented()
}
