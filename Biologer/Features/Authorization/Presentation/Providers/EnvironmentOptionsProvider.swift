protocol EnvironmentOptionsProviding {
    var defaultOption: EnvironmentOption { get }
    var options: [EnvironmentOption] { get }

    func option(for id: EnvironmentID) -> EnvironmentOption
}

/// Adds localized authorization UI content to stable environment identities.
struct DefaultEnvironmentOptionsProvider: EnvironmentOptionsProviding {
    private let configurationProvider: EnvironmentConfigurationProviding

    init(configurationProvider: EnvironmentConfigurationProviding) {
        self.configurationProvider = configurationProvider
    }

    var defaultOption: EnvironmentOption {
        option(for: configurationProvider.defaultID)
    }

    var options: [EnvironmentOption] {
        configurationProvider.allIDs.map(option(for:))
    }

    func option(for id: EnvironmentID) -> EnvironmentOption {
        let presentation = presentation(for: id)
        return EnvironmentOption(
            id: id,
            title: presentation.title,
            image: presentation.image
        )
    }

    private func presentation(for id: EnvironmentID) -> (title: String, image: String) {
        switch id {
        case .serbia:
            ("Env.lb.serbia".localized, "serbia_flag")
        case .croatia:
            ("Env.lb.croatia".localized, "croatia_flag")
        case .bosniaAndHerzegovina:
            ("Env.lb.bosniaAndHerzegovina".localized, "bosnia_flag_icon")
        case .montenegro:
            ("Env.lb.montenegro".localized, "montenegro_flag_icon")
        case .development:
            ("Env.lb.developer".localized, "hammer_icon")
        }
    }
}
