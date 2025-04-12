//
//  StyleFont.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI
//
//extension Font {
//    
//    static func appFont(_ font: CustomTheme.FontKey) -> Font {
//        return DesignSystem.shared.font(font)
//    }
//    
//}
//
//struct AppFontViewModifier: ViewModifier {
//    
//    var font: CustomTheme.FontKey!
//    
//    func body(content: Content) -> some View {
//        content
//            .font(.appFont(font))
//    }
//    
//}
//
//extension View {
//    
//    func appFont(with font: CustomTheme.FontKey) -> some View {
//        modifier(AppFontViewModifier(font: font))
//    }
//    
//}
//
//extension Label {
//    
//    func appFont(with font: CustomTheme.FontKey) -> some View {
//        modifier(AppFontViewModifier(font: font))
//    }
//    
//}
//
//extension Text {
//    
//    func appFont(with font: CustomTheme.FontKey) -> some View {
//        modifier(AppFontViewModifier(font: font))
//    }
//    
//}
//
extension UIFont {
    
    class func rounded(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
        
    }
    
    class func serif(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.serif) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
        
    }
    
}
