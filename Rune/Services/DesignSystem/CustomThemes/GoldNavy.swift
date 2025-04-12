//
//  GoldNavy.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension Theme {
    
    static let GOLD_NAVY = Theme(
        id: "GOLD_NAVY",
        accentColor: .color(Color(hex: "#D4AF37")),            // Gold
        accentColorSecondary: .color(Color(hex: "#A67C00")),     // Darker gold
        background: .init(
            primary: .color(Color(hex: "#0A1A2F")),    // Deep navy
            secondary: .color(Color(hex: "#0E2439")),  // Slightly lighter navy
            tertiary: .color(Color(hex: "#162E44")),   // For cards, elevated surfaces
            quaternary: .color(Color(hex: "#213B52"))  // For shadows or fills
        ),
        textColor: .init(
            title: .color(Color(hex: "#F5F5F5")),         // Soft white
            titleInverted: .color(Color(hex: "#0A1A2F")),   // Navy (inverse of title)
            body: .color(Color(hex: "#B0B0B0")),            // Muted text
            bodyInverted: .color(Color(hex: "#B0B0B0"))       // Muted text
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

extension Theme {

    static let ALTERNATE = Theme(
        id: "ALTERNATE",
        accentColor: .color(.indigo),
        accentColorSecondary: .color(.indigo),
        background: .init(
            primary: .color(.init(uiColor: .white)),
            secondary: .color(.init(uiColor: .systemGray6)),
            tertiary: .color(.init(uiColor: .systemGray4)),
            quaternary: .color(.init(uiColor: .systemGray2))
        ),
        textColor: .init(
            title: .color(.white),
            titleInverted: .color(.black),
            body: .color(.init(white: 0.8)),
            bodyInverted: .color(.init(white: 0.2))
        ),
        spacing: .init(
            extraSmall: 0,
            small: 0,
            small2: 0,
            medium: 0,
            medium2: 0,
            large: 0,
            extraLarge: 0
        ),
        radius: .init(
            extraSmall: 0,
            small: 0,
            small2: 0,
            medium: 0,
            medium2: 0,
            large: 0,
            extraLarge: 0
        ),
        fonts: .init(
            title: .rounded(size: 28, weight: .bold),
            subtitle: .rounded(size: 20, weight: .medium),
            body: .rounded(size: 16, weight: .regular),
            caption: .rounded(size: 12, weight: .light)
        ),
        shadow: .init(
            card: DecodableShadow(color: Color.green.opacity(0.1), radius: 8, x: 0, y: 4),
            subtle: DecodableShadow(color: Color.green.opacity(0.05), radius: 4, x: 0, y: 2),
            offset: DecodableShadow(color: Color.green.opacity(0.2), radius: 10, x: 10, y: 10),
            neon: DecodableShadow(color: Color.green.opacity(0.7), radius: 20, x: 0, y: 0),
            hard: DecodableShadow(color: Color.green.opacity(0.25), radius: 0, x: 0, y: 2),
            inner: DecodableShadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    )
    
}
