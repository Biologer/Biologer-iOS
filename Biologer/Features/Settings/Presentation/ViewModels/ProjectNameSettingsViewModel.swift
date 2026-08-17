import Foundation

@MainActor
final class ProjectNameSettingsViewModel: ObservableObject {
    @Published var projectName: String

    private let useCase: SettingsPreferencesUseCase

    init(useCase: SettingsPreferencesUseCase) {
        self.useCase = useCase
        projectName = useCase.preferences().projectName
    }

    func save() {
        let normalizedProjectName = projectName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        projectName = normalizedProjectName
        useCase.saveProjectName(normalizedProjectName)
    }
}
