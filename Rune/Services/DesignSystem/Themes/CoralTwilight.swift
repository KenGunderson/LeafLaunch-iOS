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
        shadow: .default
    )
    
}
