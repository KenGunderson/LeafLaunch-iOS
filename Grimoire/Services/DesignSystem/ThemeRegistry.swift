//
//  ThemeRegistry.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

enum AvailableTheme: String, CaseIterable, Sendable {
    
    case glowPro
    case nudgeLight
    case lightCyan
    case sunset
    case sage
    case arctic
    case candy
    case periwinkle
    case earth
    case nudgeDark
    case forest
    case roseGold
    case royal
    case midnight
    case matrix
    case neon
    
    static var lightThemes: [AvailableTheme] {
        return [
            .glowPro,
            .nudgeLight,
            .lightCyan,
            .sunset,
            .sage,
            .arctic,
            .candy,
            .periwinkle,
            .earth,
        ]
    }
    
    static var darkThemes: [AvailableTheme] {
        return [
            .nudgeDark,
            .forest,
            .roseGold,
            .royal,
            .midnight,
            .matrix,
            .neon,
        ]
    }
    
    var displayName: String {
        switch self {
        case .glowPro: return "GlowPro"
        case .nudgeLight: return "Nudge Light"
        case .nudgeDark: return "Nudge Dark"
        case .periwinkle: return "Periwinkle"
        case .lightCyan: return "Teal Cyan"
        case .matrix: return "Matrix"
        case .sunset: return "Sunset"
        case .midnight: return "Midnight"
        case .forest: return "Forest"
        case .candy: return "Candy Pop"
        case .royal: return "Royal"
        case .earth: return "Earth"
        case .arctic: return "Arctic"
        case .roseGold: return "Rose Gold"
        case .sage: return "Sage"
        case .neon: return "Neon"
        }
    }
    
    var shortDisplayName: String {
        switch self {
        case .glowPro: return "Mint"
        case .nudgeLight: return "Light"
        case .nudgeDark: return "Dark"
        case .periwinkle: return "Periwinkle"
        case .lightCyan: return "Tealy"
        case .matrix: return "Matrix"
        case .sunset: return "Sunset"
        case .midnight: return "Midnight"
        case .forest: return "Forest"
        case .candy: return "Candy"
        case .royal: return "Royal"
        case .earth: return "Earth"
        case .arctic: return "Arctic"
        case .roseGold: return "Rose"
        case .sage: return "Sage"
        case .neon: return "Neon"
        }
    }
    
    var description: String {
        switch self {
        case .glowPro: return "Throwback color"
        case .nudgeLight: return "A bright, clean theme with a soft and polished feel."
        case .nudgeDark: return "A sleek dark theme designed for a calm and focused experience."
        case .periwinkle: return "A dreamy, soft version of Nudge with airy blue tones."
        case .lightCyan: return "A fresh light theme with cool teal and cyan tones."
        case .matrix: return "A high-contrast digital terminal theme inspired by the Matrix."
        case .sunset: return "Warm orange and coral tones inspired by a golden hour sky."
        case .midnight: return "Deep indigo and violet hues for a luxurious night-time feel."
        case .forest: return "Rich dark greens for a grounded, natural atmosphere."
        case .candy: return "Vibrant neon pinks and purples — bold, playful, and alive."
        case .royal: return "Deep navy with electric gold accents — premium and sophisticated."
        case .earth: return "Warm terracotta and cream tones for an earthy, editorial feel."
        case .arctic: return "Cool slate and electric blue — minimal, crisp, professional."
        case .roseGold: return "Deep charcoal with rose gold accents — elegant and modern."
        case .sage: return "Soft sage greens and warm linen — calm, natural, restful."
        case .neon: return "True black with neon cyan — cyberpunk energy at full blast."
        }
    }
    
    var iconName: String {
        switch self {
        case .glowPro: return "person.fill"
        case .nudgeLight: return "sun.max.fill"
        case .nudgeDark: return "moon.fill"
        case .periwinkle: return "beach.umbrella.fill"
        case .lightCyan: return "drop.fill"
        case .matrix: return "terminal.fill"
        case .sunset: return "sunset.fill"
        case .midnight: return "sparkles"
        case .forest: return "leaf.fill"
        case .candy: return "star.fill"
        case .royal: return "crown.fill"
        case .earth: return "globe.americas.fill"
        case .arctic: return "snowflake"
        case .roseGold: return "diamond.fill"
        case .sage: return "tree.fill"
        case .neon: return "bolt.fill"
        }
    }
    
    init?(storedRawValue rawValue: String) {

        if let availableTheme = Self(rawValue: rawValue) {
            
            self = availableTheme
            return
            
        }
        
        self = .nudgeLight
        
    }

    init?(theme: any ThemeProtocol) {

        guard let availableTheme = Self.allCases.first(where: { $0.theme().id == theme.id }) else {
            return nil
        }

        self = availableTheme

    }

    func theme() -> Theme {

        switch self {
        case .glowPro: return Theme.GLOW_PRO
        case .nudgeLight: return Theme.NUDGE_LIGHT
        case .nudgeDark: return Theme.NUDGE_DARK
        case .periwinkle: return Theme.NUDGE_PERIWINKLE
        case .lightCyan: return Theme.TEAL_CYAN_LIGHT
        case .matrix: return Theme.MATRIX
        case .sunset: return Theme.NUDGE_SUNSET
        case .midnight: return Theme.NUDGE_MIDNIGHT
        case .forest: return Theme.NUDGE_FOREST
        case .candy: return Theme.NUDGE_CANDY
        case .royal: return Theme.NUDGE_NAVY
        case .earth: return Theme.NUDGE_EARTH
        case .arctic: return Theme.NUDGE_ARCTIC
        case .roseGold: return Theme.NUDGE_ROSE_GOLD
        case .sage: return Theme.NUDGE_SAGE
        case .neon: return Theme.NUDGE_NEON
        }

    }

    func foregroundColor() -> Color {
        return theme().foreground.primary.asColor ?? .black
    }

    func backgroundColor() -> Color {
        return theme().background.primary.asColor ?? .black
    }
    
}
