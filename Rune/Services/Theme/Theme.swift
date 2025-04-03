//
//  Theme.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/1/25.
//

import SwiftUI

class Theme: Equatable, Hashable {
    
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case .EMERALD_NOIR: hasher.combine("EMERALD_NOIR")
        case .CORAL_TWILIGHT: hasher.combine("CORAL_TWILIGHT")
        case .NEON_NIGHT: hasher.combine("NEON_NIGHT")
        case .SANDSTONE_DUSK: hasher.combine("SANDSTONE_DUSK")
        case .GOLD_NAVY: hasher.combine("GOLD_NAVY")
        default: fatalError("Unsupported theme")
        }
        
    }
    
    enum Background {
        
        case primary
        case secondary
        case tertiary
        case quad
        
    }

    enum TextColor {
        
        case title
        case titleInverted
        case body
        case bodyInverted
        
    }
    
    let id: String
    
    let accentColor: Color
    let accentColorSecondary: Color

    let backgroundColorProvider: (Background) -> Color
    let textColorProvider: (TextColor) -> Color
    
    var accentColorGradient: AnyGradient {
        return self.accentColor.gradient
    }

    var backgroundGradient: AnyGradient {
        return self.background(.primary).gradient
    }

    func background(_ type: Background) -> Color {
        backgroundColorProvider(type)
    }

    func textColor(_ type: TextColor) -> Color {
        textColorProvider(type)
    }
    
    init(id: String,
         accentColor: Color,
         accentColorSecondary: Color,
         backgroundColorProvider: @escaping (Background) -> Color,
         textColorProvider: @escaping (TextColor) -> Color) {
        
        self.id = id
        self.accentColor = accentColor
        self.accentColorSecondary = accentColorSecondary
        self.backgroundColorProvider = backgroundColorProvider
        self.textColorProvider = textColorProvider
        
    }
    
}

extension Theme {
    
    static let CORAL_TWILIGHT = Theme(
        id: "CORAL_TWILIGHT",
        accentColor: Color(hex: "#FF6B6B"),
        accentColorSecondary: Color(hex: "#B23A48"),
        backgroundColorProvider: { background in
            switch background {
            case .primary: return Color(hex: "#26141F")
            case .secondary: return Color(hex: "#3B2734")
            case .tertiary: return Color(hex: "#4E2C3D")
            case .quad: return Color(hex: "#6B3A50")
            }
        },
        textColorProvider: { textColor in
            switch textColor {
            case .title: return Color(hex: "#FFF5F5")
            case .titleInverted: return Color(hex: "#26141F")
            case .body, .bodyInverted: return Color(hex: "#F2BDBD")
            }
        }
    )
    
    static let NEON_NIGHT = Theme(
        id: "NEON_NIGHT",
        accentColor: Color(hex: "#00FFFF"),
        accentColorSecondary: Color(hex: "#7A00FF"),
        backgroundColorProvider: { background in
            switch background {
            case .primary: return Color(hex: "#080A14")
            case .secondary: return Color(hex: "#111322")
            case .tertiary: return Color(hex: "#1B1E32")
            case .quad: return Color(hex: "#272B45")
            }
        },
        textColorProvider: { textColor in
            switch textColor {
            case .title: return Color(hex: "#E5FFFF")
            case .titleInverted: return Color(hex: "#080A14")
            case .body, .bodyInverted: return Color(hex: "#A5C7D0")
            }
        }
    )
    
    static let EMERALD_NOIR = Theme(
        id: "EMERALD_NOIR",
        accentColor: Color(hex: "#2ECC71"),
        accentColorSecondary: Color(hex: "#117A45"),
        backgroundColorProvider: { background in
            switch background {
            case .primary: return Color(hex: "#0A0F0C")
            case .secondary: return Color(hex: "#111712")
            case .tertiary: return Color(hex: "#1A2A24")
            case .quad: return Color(hex: "#264C3E")
            }
        },
        textColorProvider: { textColor in
            switch textColor {
            case .title: return Color(hex: "#F0FFF4")
            case .titleInverted: return Color(hex: "#0A0F0C")
            case .body, .bodyInverted: return Color(hex: "#A7D7C5")
            }
        }
    )
    
    static let SANDSTONE_DUSK = Theme(
        id: "SANDSTONE_DUSK",
        accentColor: Color(hex: "#D2B48C"),
        accentColorSecondary: Color(hex: "#7B5E3C"),
        backgroundColorProvider: { background in
            switch background {
            case .primary: return Color(hex: "#1E1A16")
            case .secondary: return Color(hex: "#2A2521")
            case .tertiary: return Color(hex: "#3A332D")
            case .quad: return Color(hex: "#4D443B")
            }
        },
        textColorProvider: { textColor in
            switch textColor {
            case .title: return Color(hex: "#FDF7F0")
            case .titleInverted: return Color(hex: "#1E1A16")
            case .body, .bodyInverted: return Color(hex: "#C9B4A3")
            }
        }
    )
    
    static let GOLD_NAVY = Theme(
        id: "GOLD_NAVY",
        accentColor: Color(hex: "#D4AF37"),            // Gold
        accentColorSecondary: Color(hex: "#A67C00"),   // Darker gold
        backgroundColorProvider: { background in
            switch background {
            case .primary: return Color(hex: "#0A1A2F")      // Deep navy
            case .secondary: return Color(hex: "#0E2439")    // Slightly lighter navy
            case .tertiary: return Color(hex: "#162E44")     // For cards, elevated surfaces
            case .quad: return Color(hex: "#213B52")         // For shadows or fills
            }
        },
        textColorProvider: { textColor in
            switch textColor {
            case .title: return Color(hex: "#F5F5F5")         // Soft white
            case .titleInverted: return Color(hex: "#0A1A2F") // Inverted: navy bg
            case .body, .bodyInverted: return Color(hex: "#B0B0B0") // Muted text
            }
        }
    )
    
}
