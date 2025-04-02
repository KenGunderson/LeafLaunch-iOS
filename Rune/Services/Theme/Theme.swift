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
        case .INDIGO: hasher.combine("INDIGO")
        case .BLUE: hasher.combine("BLUE")
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
    
    static let INDIGO = Theme(
        id: "INDIGO",
        accentColor: Color(hex: "#4B0082"),
        accentColorSecondary: Color(hex: "#8A2BE2"),
        backgroundColorProvider: { background in
            switch background {
            case .primary: return Color(hex: "#F5F3FF")
            case .secondary: return Color(hex: "#EDE9FE")
            case .tertiary: return Color(hex: "#DDD6FE")
            case .quad: return Color(hex: "#C4B5FD")
            }
        },
        textColorProvider: { textColor in
            switch textColor {
            case .title: return Color(hex: "#1C1C2E")
            case .titleInverted: return Color(hex: "#FFFFFF")
            case .body, .bodyInverted: return Color(hex: "#A9A9C5")
            }
        }
    )
    
    static let BLUE = Theme(
        id: "BLUE",
        accentColor: Color(hex: "#00AEEF"),
        accentColorSecondary: Color(hex: "#00FFF7"),
        backgroundColorProvider: { background in
            switch background {
            case .primary: return Color(hex: "#E6F7FF")
            case .secondary: return Color(hex: "#D0F0FF")
            case .tertiary: return Color(hex: "#B0E0FF")
            case .quad: return Color(hex: "#A0DFFF")
            }
        },
        textColorProvider: { textColor in
            switch textColor {
            case .title: return Color(hex: "#FFFFFF")
            case .titleInverted: return Color(hex: "#002A47")
            case .body, .bodyInverted: return Color(hex: "#A0B3C1")
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
