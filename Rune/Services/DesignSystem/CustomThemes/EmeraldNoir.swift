//
//  EmeraldNoir.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension Theme {
    
    static let EMERALD_NOIR = Theme(
        id: "EMERALD_NOIR",
        accentColor: .color(Color(hex: "#2ECC71")),
        accentColorSecondary: .color(Color(hex: "#117A45")),
        background: .init(
            primary: .color(Color(hex: "#0A0F0C")),
            secondary: .color(Color(hex: "#111712")),
            tertiary: .color(Color(hex: "#1A2A24")),
            quaternary: .color(Color(hex: "#264C3E"))
        ),
        textColor: .init(
            title: .color(Color(hex: "#F0FFF4")),
            titleInverted: .color(Color(hex: "#0A0F0C")),
            body: .color(Color(hex: "#A7D7C5")),
            bodyInverted: .color(Color(hex: "#A7D7C5"))
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
