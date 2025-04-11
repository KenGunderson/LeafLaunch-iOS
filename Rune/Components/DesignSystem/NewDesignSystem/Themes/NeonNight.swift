//
//  Untitled.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension CustomTheme {
    
    static let NEON_NIGHT = CustomTheme(
        id: "NEON_NIGHT",
        accentColor: .color(Color(hex: "#00FFFF")),
        accentColorSecondary: .color(Color(hex: "#7A00FF")),
        background: .init(
            primary: .color(Color(hex: "#080A14")),
            secondary: .color(Color(hex: "#111322")),
            tertiary: .color(Color(hex: "#1B1E32")),
            quaternary: .color(Color(hex: "#272B45"))
        ),
        textColor: .init(
            title: .color(Color(hex: "#E5FFFF")),
            titleInverted: .color(Color(hex: "#080A14")),
            body: .color(Color(hex: "#A5C7D0")),
            bodyInverted: .color(Color(hex: "#A5C7D0"))
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
