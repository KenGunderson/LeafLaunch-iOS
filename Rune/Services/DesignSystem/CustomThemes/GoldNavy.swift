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
        fonts: .default,
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
            BILLBOARD_B1: .serif(size: 64, weight: .heavy),
            HEADER_H1: .serif(size: 36, weight: .heavy),
            HEADER_H5: .serif(size: 28, weight: .heavy),
            HEADER_H6: .serif(size: 22, weight: .heavy),
            HEADER_H10: .serif(size: 20, weight: .heavy),
            HEADER_H15: .serif(size: 16, weight: .heavy),
            TITLE_T1: .serif(size: 12, weight: .medium),
            TITLE_T2: .serif(size: 12, weight: .bold),
            TITLE_T4: .serif(size: 14, weight: .bold),
            TITLE_T5: .serif(size: 16, weight: .bold),
            TITLE_T6: .serif(size: 18, weight: .semibold),
            TITLE_T8: .serif(size: 22, weight: .semibold),
            TITLE_T10: .serif(size: 24, weight: .heavy),
            BODY_B1: .serif(size: 12, weight: .regular),
            BODY_B4: .serif(size: 14, weight: .regular),
            BODY_B5: .serif(size: 16, weight: .regular),
            BODY_B10: .serif(size: 18, weight: .regular)
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
