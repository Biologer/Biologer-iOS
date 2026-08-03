import UIKit

enum BiologerUIColor {
    // Brand palette
    static let brandAccent = color(red: 123, green: 188, blue: 74)      // #7BBC4A
    static let brandStrong = color(red: 79, green: 122, blue: 46)      // #4F7A2E
    static let brandSoft = color(red: 221, green: 238, blue: 207)      // #DDEECF
    static let brandCanvas = color(red: 244, green: 240, blue: 230)    // #F4F0E6
    static let brandInk = color(red: 47, green: 58, blue: 44)          // #2F3A2C

    // Semantic roles
    static let accent = brandAccent
    static let primaryActionBackground = brandStrong
    static let primaryActionForeground = UIColor.white
    static let destructive = UIColor.systemRed

    static let pageBackground = adaptiveColor(
        light: brandCanvas,
        dark: .systemGroupedBackground
    )

    static let surface = adaptiveColor(
        light: .white,
        dark: .secondarySystemGroupedBackground
    )

    static let textPrimary = adaptiveColor(
        light: brandInk,
        dark: .label
    )

    static let sectionTitle = adaptiveColor(
        light: brandStrong,
        dark: brandSoft
    )

    static let iconBackground = adaptiveColor(
        light: brandSoft,
        dark: brandStrong.withAlphaComponent(0.32)
    )

    static let selectedSurface = adaptiveColor(
        light: brandSoft.withAlphaComponent(0.58),
        dark: brandStrong.withAlphaComponent(0.24)
    )

    private static func color(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        UIColor(
            red: red / 255,
            green: green / 255,
            blue: blue / 255,
            alpha: 1
        )
    }

    private static func adaptiveColor(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        }
    }
}
