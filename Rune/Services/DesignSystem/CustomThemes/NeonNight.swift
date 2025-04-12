//
//  Untitled.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension Theme {
    
    static let NEON_NIGHT = Theme(
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
        shadow: .default
    )
    
}
