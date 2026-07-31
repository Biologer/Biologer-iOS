import Foundation

final class ProjectNameSettingsViewModel: ObservableObject {
    @Published var projectName: String

    private let useCase: SettingsPreferencesUseCase

    init(useCase: SettingsPreferencesUseCase) {
        self.useCase = useCase
        projectName = useCase.preferences().projectName
    }

    func save() {
        useCase.saveProjectName(projectName)
        projectName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
