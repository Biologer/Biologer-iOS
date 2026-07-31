import SwiftUI
import UIKit

enum SettingsColorPalette {
    static let primary = color(red: 123, green: 188, blue: 74)       // #7BBC4A
    static let forest = color(red: 79, green: 122, blue: 46)        // #4F7A2E
    static let softGreen = color(red: 221, green: 238, blue: 207)   // #DDEECF
    static let warmCream = color(red: 244, green: 240, blue: 230)   // #F4F0E6
    static let darkOlive = color(red: 47, green: 58, blue: 44)      // #2F3A2C

    static let pageBackground = adaptiveColor(
        light: uiColor(red: 244, green: 240, blue: 230),
        dark: .systemGroupedBackground
    )

    static let surface = adaptiveColor(
        light: .white,
        dark: .secondarySystemGroupedBackground
    )

    static let primaryText = adaptiveColor(
        light: uiColor(red: 47, green: 58, blue: 44),
        dark: .label
    )

    static let sectionTitle = adaptiveColor(
        light: uiColor(red: 79, green: 122, blue: 46),
        dark: uiColor(red: 221, green: 238, blue: 207)
    )

    static let iconBackground = adaptiveColor(
        light: uiColor(red: 221, green: 238, blue: 207),
        dark: uiColor(red: 79, green: 122, blue: 46).withAlphaComponent(0.32)
    )

    static let selectedSurface = adaptiveColor(
        light: uiColor(red: 221, green: 238, blue: 207).withAlphaComponent(0.58),
        dark: uiColor(red: 79, green: 122, blue: 46).withAlphaComponent(0.24)
    )

    private static func color(red: CGFloat, green: CGFloat, blue: CGFloat) -> Color {
        Color(uiColor: uiColor(red: red, green: green, blue: blue))
    }

    private static func uiColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        UIColor(
            red: red / 255,
            green: green / 255,
            blue: blue / 255,
            alpha: 1
        )
    }

    private static func adaptiveColor(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: UIColor { traits in
                traits.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}
