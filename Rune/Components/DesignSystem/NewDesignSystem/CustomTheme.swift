//
//  CustomTheme.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

struct CustomTheme: Equatable, Identifiable, ThemeType {
    
    static func == (lhs: CustomTheme, rhs: CustomTheme) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let accentColor: ColorSource
    let accentColorSecondary: ColorSource
    let background: Background
    let textColor: TextColor
    let spacing: Spacing
    let radius: Radius
    let fonts: Fonts
    let shadow: Shadow

    struct Background {
        
        let primary: ColorSource
        let secondary: ColorSource
        let tertiary: ColorSource
        let quaternary: ColorSource
        
        func value(for key: BackgroundKey) -> ColorSource {
            
            switch key {
            case .primary: return primary
            case .secondary: return secondary
            case .tertiary: return tertiary
            case .quaternary: return quaternary
            }
            
        }
        
    }

    struct TextColor {
        
        let title: ColorSource
        let titleInverted: ColorSource
        let body: ColorSource
        let bodyInverted: ColorSource
        
        func value(for key: TextColorKey) -> ColorSource {
            
            switch key {
            case .title: return title
            case .titleInverted: return titleInverted
            case .body: return body
            case .bodyInverted: return bodyInverted
            }
            
        }
        
    }

    struct Spacing {
        
        let none: CGFloat = 0
        let extraSmall: CGFloat
        let small: CGFloat
        let small2: CGFloat
        let medium: CGFloat
        let medium2: CGFloat
        let large: CGFloat
        let extraLarge: CGFloat

        func value(for key: CustomTheme.SpacingKey) -> CGFloat {
            
            switch key {
            case .none: return none
            case .extraSmall: return extraSmall
            case .small: return small
            case .small2: return small2
            case .medium: return medium
            case .medium2: return medium2
            case .large: return large
            case .extraLarge: return extraLarge
            case .custom(let value): return value
            }
            
        }
        
    }

    struct Radius {
        
        let extraSmall: CGFloat
        let small: CGFloat
        let small2: CGFloat
        let medium: CGFloat
        let medium2: CGFloat
        let large: CGFloat
        let extraLarge: CGFloat

        func value(for key: RadiusKey) -> CGFloat {
            
            switch key {
            case .extraSmall: return extraSmall
            case .small: return small
            case .small2: return small2
            case .medium: return medium
            case .medium2: return medium2
            case .large: return large
            case .extraLarge: return extraLarge
            case .custom(let value): return value
            }
            
        }
        
    }

    struct Fonts {
        
        let title: UIFont
        let subtitle: UIFont
        let body: UIFont
        let caption: UIFont

        func value(for key: FontKey) -> UIFont {
            
            switch key {
            case .title: return title
            case .subtitle: return subtitle
            case .body: return body
            case .caption: return caption
            }
            
        }
        
    }
    
    struct DecodableShadow {
        
        var color: Color
        var radius: CGFloat
        var x: CGFloat
        var y: CGFloat
        
    }
    
    struct Shadow {
        
        let card: DecodableShadow
        let subtle: DecodableShadow
        let offset: DecodableShadow
        let neon: DecodableShadow
        let hard: DecodableShadow
        let inner: DecodableShadow
        
        func value(for key: ShadowKey) -> DecodableShadow {
            
            switch key {
            case .card: return card
            case .subtle: return subtle
            case .offset: return offset
            case .neon: return neon
            case .hard: return hard
            case .inner: return inner
            }
            
        }
        
    }
    
    enum BackgroundKey {
        
        case primary
        case secondary
        case tertiary
        case quaternary
        
    }
    
    enum SpacingKey {
        
        case none
        case extraSmall
        case small
        case small2
        case medium
        case medium2
        case large
        case extraLarge
        case custom(CGFloat)
        
    }
    
    enum RadiusKey {
        
        case extraSmall
        case small
        case small2
        case medium
        case medium2
        case large
        case extraLarge
        case custom(CGFloat)
        
    }
    
    enum FontKey {
        
        case title
        case subtitle
        case body
        case caption
        
    }
    
    enum TextColorKey {
        
        case title
        case titleInverted
        case body
        case bodyInverted
        
    }
    
    enum ShadowKey {
        
        case card
        case subtle
        case offset
        case neon
        case hard
        case inner
        
    }
    
}
