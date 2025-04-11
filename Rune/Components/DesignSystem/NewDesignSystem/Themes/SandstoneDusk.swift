//
//  SandstoneDusk.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension CustomTheme {
    
    static let SANDSTONE_DUSK = CustomTheme(
        id: "SANDSTONE_DUSK",
        accentColor: .color(Color(hex: "#D2B48C")),
        accentColorSecondary: .color(Color(hex: "#7B5E3C")),
        background: .init(
            primary: .color(Color(hex: "#1E1A16")),
            secondary: .color(Color(hex: "#2A2521")),
            tertiary: .color(Color(hex: "#3A332D")),
            quaternary: .color(Color(hex: "#4D443B"))
        ),
        textColor: .init(
            title: .color(Color(hex: "#FDF7F0")),
            titleInverted: .color(Color(hex: "#1E1A16")),
            body: .color(Color(hex: "#C9B4A3")),
            bodyInverted: .color(Color(hex: "#C9B4A3"))
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
            card: DecodableShadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4),
            subtle: DecodableShadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2),
            offset: DecodableShadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10),
            neon: DecodableShadow(color: Color.blue.opacity(0.7), radius: 20, x: 0, y: 0),
            hard: DecodableShadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 2),
            inner: DecodableShadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    )
    
}
