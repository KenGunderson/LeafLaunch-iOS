//
//  GPFont.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/15/25.
//

import SwiftUI

extension UIFont {
    
    private enum SFProDisplay {
        
        static let black = "SFProDisplay-Black"
        static let blackItalic = "SFProDisplay-BlackItalic"
        static let bold = "SFProDisplay-Bold"
        static let boldItalic = "SFProDisplay-BoldItalic"
        static let heavy = "SFProDisplay-Heavy"
        static let heavyItalic = "SFProDisplay-HeavyItalic"
        static let light = "SFProDisplay-Light"
        static let lightItalic = "SFProDisplay-LightItalic"
        static let medium = "SFProDisplay-Medium"
        static let mediumItalic = "SFProDisplay-MediumItalic"
        static let regular = "SFProDisplay-Regular"
        static let regularItalic = "SFProDisplay-RegularItalic"
        static let semibold = "SFProDisplay-Semibold"
        static let semiboldItalic = "SFProDisplay-SemiboldItalic"
        static let thin = "SFProDisplay-Thin"
        static let thinItalic = "SFProDisplay-ThinItalic"
        static let ultralight = "SFProDisplay-Ultralight"
        static let ultralightItalic = "SFProDisplay-UltralightItalic"
        
    }
    
    static func sfDisplay(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        let name: String
        
        switch weight {
        case .regular: name = SFProDisplay.regular
        case .medium: name = SFProDisplay.medium
        case .semibold:  name = SFProDisplay.semibold
        case .bold: name = SFProDisplay.bold
        case .heavy: name = SFProDisplay.heavy
        case .light: name = SFProDisplay.regular
        case .thin: name = SFProDisplay.regular
        case .ultraLight:  name = SFProDisplay.regular
        case .black: name = SFProDisplay.heavy
        default: name = SFProDisplay.regular
        }
        
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
        
    }
    
}

extension Theme.Fonts {

    static var sfDisplay: Theme.Fonts {
        Theme.Fonts(
            BILLBOARD_1: .sfDisplay(size: 48, weight: .bold),
            BILLBOARD_2: .sfDisplay(size: 56, weight: .bold),
            BILLBOARD_3: .sfDisplay(size: 64, weight: .bold),
            BILLBOARD_4: .sfDisplay(size: 72, weight: .bold),
            BILLBOARD_5: .sfDisplay(size: 80, weight: .bold),

            HEADER_5: .sfDisplay(size: 36, weight: .bold),
            HEADER_4: .sfDisplay(size: 28, weight: .bold),
            HEADER_3: .sfDisplay(size: 22, weight: .bold),
            HEADER_2: .sfDisplay(size: 20, weight: .bold),
            HEADER_1: .sfDisplay(size: 16, weight: .bold),

            TITLE_1: .sfDisplay(size: 12, weight: .medium),
            TITLE_2: .sfDisplay(size: 12, weight: .semibold),
            TITLE_3: .sfDisplay(size: 14, weight: .semibold),
            TITLE_4: .sfDisplay(size: 16, weight: .semibold),
            TITLE_5: .sfDisplay(size: 18, weight: .semibold),
            TITLE_6: .sfDisplay(size: 22, weight: .semibold),
            TITLE_7: .sfDisplay(size: 24, weight: .semibold),

            BODY_1: .sfDisplay(size: 12, weight: .regular),
            BODY_2: .sfDisplay(size: 14, weight: .regular),
            BODY_3: .sfDisplay(size: 16, weight: .regular),
            BODY_4: .sfDisplay(size: 18, weight: .regular)
        )
    }
    
}
