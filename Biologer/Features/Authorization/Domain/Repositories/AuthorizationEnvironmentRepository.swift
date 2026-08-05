import Foundation

protocol AuthorizationEnvironmentRepository {
    func save(_ environment: AppEnvironment)
}
