//
//  GoldLight.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI
extension CustomTheme {
    
    static let GOLD_LIGHT = CustomTheme(
        id: "GOLD_LIGHT",
        accentColor: .color(Color(hex: "#D4AF37")),            // Gold accent
        accentColorSecondary: .color(Color(hex: "#2ECC71")),     // Emerald accent
        background: .init(
            primary: .color(Color(hex: "#FFFCF5")),      // A warm, off-white background
            secondary: .color(Color(hex: "#FFF8E1")),    // Light, golden-beige tone for secondary surfaces
            tertiary: .color(Color(hex: "#E8F5E9")),     // A gentle pastel mint for elevated surfaces/cards
            quaternary: .color(Color(hex: "#E0E0E0"))    // A subtle light gray for shadows or fills
        ),
        textColor: .init(
            title: .color(Color(hex: "#0A1A2F")),         // Dark navy inspired by your GOLD_NAVY for strong contrast
            titleInverted: .color(Color(hex: "#FFFFFF")),   // Inverted (white) for contrasting surfaces
            body: .color(Color(hex: "#424242")),            // Dark gray for legible body text
            bodyInverted: .color(Color(hex: "#FFFFFF"))
        ),
        spacing: .default,
        radius: .default,
        fonts: .init(
            title: .rounded(size: 28, weight: .bold),
            subtitle: .rounded(size: 20, weight: .medium),
            body: .rounded(size: 16, weight: .regular),
            caption: .rounded(size: 12, weight: .light)
        ),
        shadow: .init(
            card: DecodableShadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2),
            subtle: DecodableShadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1),
            offset: DecodableShadow(color: Color.black.opacity(0.1), radius: 8, x: 4, y: 4),
            neon: DecodableShadow(color: Color.green.opacity(0.5), radius: 12, x: 0, y: 0),
            hard: DecodableShadow(color: Color.black.opacity(0.15), radius: 0, x: 0, y: 1),
            inner: DecodableShadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    )
    
}
