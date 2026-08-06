import Foundation

public struct EnvironmentViewModel: Identifiable, Codable, Equatable {
    public let id: Int
    public let title: String
    public let image: String
    public let env: AppEnvironment
    public private(set) var isSelected: Bool

    init(
        id: Int,
        title: String,
        image: String,
        env: AppEnvironment,
        isSelected: Bool
    ) {
        self.id = id
        self.title = title
        self.env = env
        self.image = image
        self.isSelected = isSelected
    }

    public mutating func changeIsSelected(value: Bool) {
        isSelected = value
    }

    public static func == (
        lhs: EnvironmentViewModel,
        rhs: EnvironmentViewModel
    ) -> Bool {
        lhs.id == rhs.id
    }
}
