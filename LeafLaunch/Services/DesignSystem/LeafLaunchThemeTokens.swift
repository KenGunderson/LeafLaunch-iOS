//
//  LeafLaunchThemeTokens.swift
//  LeafLaunch
//

import SwiftUI

// Web rem values resolve at 16px. The shared spacing scale keeps the 16pt field gap
// and 24pt panel padding documented in LeafLaunch-Web/DESIGN.md.
enum LeafLaunchThemeTokens {

    static let spacing = Theme.Spacing(
        extraSmall: 4,
        small: 8,
        small2: 12,
        medium: 16,
        medium2: 20,
        large: 24,
        large2: 32,
        extraLarge: 48,
        extraLarge2: 64
    )

    // CSS: xs, DEFAULT, sm, md/lg, xl, 2xl, 3xl.
    static let radius = Theme.Radius(
        extraSmall: 2,
        small: 4,
        small2: 6,
        medium: 10,
        medium2: 14,
        large: 20,
        extraLarge: 28
    )

    // Rune represents one shadow per role. Use the main layer of the web shell
    // shadows; the CSS spread and additional layers have no direct Rune equivalent.
    static let lightShadow = Theme.Shadow(
        card: .init(color: Color(hex: "#111827").opacity(0.04), radius: 2, x: 0, y: 1),
        subtle: .init(color: Color(hex: "#0A0D12").opacity(0.05), radius: 2, x: 0, y: 1),
        offset: .init(color: Color(hex: "#111827").opacity(0.06), radius: 36, x: 0, y: 18),
        neon: .init(color: .clear, radius: 0, x: 0, y: 0),
        hard: .init(color: .black.opacity(0.04), radius: 0, x: 0, y: 1),
        inner: .init(color: .black.opacity(0.05), radius: 0, x: 0, y: -2)
    )

    static let darkShadow = Theme.Shadow(
        card: .init(color: .black.opacity(0.30), radius: 2, x: 0, y: 1),
        subtle: .init(color: .black.opacity(0.18), radius: 30, x: 0, y: 14),
        offset: .init(color: .black.opacity(0.24), radius: 40, x: 0, y: 20),
        neon: .init(color: .clear, radius: 0, x: 0, y: 0),
        hard: .init(color: .black.opacity(0.30), radius: 0, x: 0, y: 1),
        inner: .init(color: .black.opacity(0.05), radius: 0, x: 0, y: -2)
    )

    static let buttonBounceStyle = Theme.ButtonBounceStyle(
        scale: 0.97,
        opacity: 1,
        brightness: 0
    )

}
