//
//  GoldNavy.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension CustomTheme {
    
    static let GOLD_NAVY = CustomTheme(
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

extension CustomTheme {

    static let ALTERNATE = CustomTheme(
        id: "ALTERNATE",
        accentColor: .color(.orange),
        accentColorSecondary: .color(.pink),
        background: .init(
            primary: .color(.black),
            secondary: .color(.gray),
            tertiary: .color(.blue),
            quaternary: .color(.init(white: 0.1))
        ),
        textColor: .init(
            title: .color(.white),
            titleInverted: .color(.black),
            body: .color(.init(white: 0.8)),
            bodyInverted: .color(.init(white: 0.2))
        ),
        spacing: .init(
            extraSmall: 6,
            small: 6,
            small2: 10,
            medium: 20,
            medium2: 20,
            large: 32,
            extraLarge: 48
        ),
        radius: .init(
            extraSmall: 4,
            small: 6,
            small2: 8,
            medium: 10,
            medium2: 12,
            large: 16,
            extraLarge: 20
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
