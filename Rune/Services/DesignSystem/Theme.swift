//
//  CustomTheme.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

struct Theme: Equatable, Identifiable, ThemeProtocol {
    
    static func == (lhs: Theme, rhs: Theme) -> Bool {
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

        func value(for key: Theme.SpacingKey) -> CGFloat {
            
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
        
        let BILLBOARD_B1: UIFont
        
        let HEADER_H1: UIFont
        let HEADER_H5: UIFont
        let HEADER_H6: UIFont
        let HEADER_H10: UIFont
        let HEADER_H15: UIFont
        
        let TITLE_T1: UIFont
        let TITLE_T2: UIFont
        let TITLE_T4: UIFont
        let TITLE_T5: UIFont
        let TITLE_T6: UIFont
        let TITLE_T8: UIFont
        let TITLE_T10: UIFont
        
        let BODY_B1: UIFont
        let BODY_B4: UIFont
        let BODY_B5: UIFont
        let BODY_B10: UIFont
                
        func value(for key: FontKey) -> UIFont {
            
            switch key {
                
            case .BILLBOARD_B1: return BILLBOARD_B1
            case .HEADER_H1: return HEADER_H1
            case .HEADER_H5: return HEADER_H5
            case .HEADER_H6: return HEADER_H6
            case .HEADER_H10: return HEADER_H10
            case .HEADER_H15: return HEADER_H15
            case .TITLE_T1: return TITLE_T1
            case .TITLE_T2: return TITLE_T2
            case .TITLE_T4: return TITLE_T4
            case .TITLE_T5: return TITLE_T5
            case .TITLE_T6: return TITLE_T6
            case .TITLE_T8: return TITLE_T8
            case .TITLE_T10: return TITLE_T10
            case .BODY_B1: return BODY_B1
            case .BODY_B4: return BODY_B4
            case .BODY_B5: return BODY_B5
            case .BODY_B10: return BODY_B10
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

        case BILLBOARD_B1
        
        case HEADER_H1
        case HEADER_H5
        case HEADER_H6
        case HEADER_H10
        case HEADER_H15
        
        case TITLE_T1
        case TITLE_T2
        case TITLE_T4
        case TITLE_T5
        case TITLE_T6
        case TITLE_T8
        case TITLE_T10
        
        case BODY_B1
        case BODY_B4
        case BODY_B5
        case BODY_B10
        
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
