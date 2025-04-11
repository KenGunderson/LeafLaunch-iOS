//
//  Untitled.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension CustomTheme {
    
    static let CORAL_TWILIGHT = CustomTheme(
        id: "CORAL_TWILIGHT",
        accentColor: .color(Color(hex: "#FF6B6B")),
        accentColorSecondary: .color(Color(hex: "#B23A48")),
        background: .init(
            primary: .color(Color(hex: "#26141F")),
            secondary: .color(Color(hex: "#3B2734")),
            tertiary: .color(Color(hex: "#4E2C3D")),
            quaternary: .color(Color(hex: "#6B3A50"))
        ),
        textColor: .init(
            title: .color(Color(hex: "#FFF5F5")),
            titleInverted: .color(Color(hex: "#26141F")),
            body: .color(Color(hex: "#F2BDBD")),
            bodyInverted: .color(Color(hex: "#F2BDBD"))
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
