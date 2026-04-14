import SwiftUI

enum X2UTheme {
    static let ink = Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255)
    static let slate = Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255)
    static let accent = Color(red: 15 / 255, green: 118 / 255, blue: 110 / 255)
    static let mint = Color(red: 14 / 255, green: 165 / 255, blue: 167 / 255)
    static let success = Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)
    static let pageBackground = Color(red: 246 / 255, green: 249 / 255, blue: 252 / 255)
    static let cardBorder = Color(red: 226 / 255, green: 232 / 255, blue: 240 / 255)

    static let heroGradient = LinearGradient(
        colors: [accent, mint, success],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
