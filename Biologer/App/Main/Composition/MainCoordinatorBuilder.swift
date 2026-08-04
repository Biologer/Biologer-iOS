enum MainUIVersion: Equatable {
    case v1
    case v2
}

@MainActor
final class MainCoordinatorBuilder {
    private let version: MainUIVersion
    private let makeLegacyCoordinator: () -> MainCoordinating
    private let makeTabCoordinator: () -> MainCoordinating

    init(
        version: MainUIVersion,
        makeLegacyCoordinator: @escaping () -> MainCoordinating,
        makeTabCoordinator: @escaping () -> MainCoordinating
    ) {
        self.version = version
        self.makeLegacyCoordinator = makeLegacyCoordinator
        self.makeTabCoordinator = makeTabCoordinator
    }

    func makeCoordinator() -> MainCoordinating {
        switch version {
        case .v1:
            makeLegacyCoordinator()
        case .v2:
            makeTabCoordinator()
        }
    }
}
