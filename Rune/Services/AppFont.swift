//
//  AppFont.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/12/23.
//

import Foundation
import SwiftUI

//enum AppFont {
//    
//    enum Billboard {
//        
//        /// 64
//        case b1
//        
//    }
//    
//    enum Header {
//        
//        /// 36 Heavy
//        case h1
//        
//        /// 28 Heavy
//        case h5
//        
//        /// 22 Heavy
//        case h6
//        
//        /// 20 Heavy
//        case h10
//        
//        /// 16 Serif Heavy
//        case h15
//        
//    }
//        
//    enum Title {
//        
//        /// 12 Medium
//        case t1
//        
//        /// 12 Bold
//        case t2
//        
//        /// 14 Bold
//        case t4
//        
//        /// 16 Bold
//        case t5
//        
//        /// 18 SemiBold
//        case t6
//        
//        /// 22 SemiBold
//        case t8
//        
//        /// 24 Heavy
//        case t10
//        
//    }
//    
//    enum Body {
//        
//        /// 12
//        case b1
//        
//        /// 14
//        case b4
//        
//        /// 16
//        case b5
//        
//        /// 18
//        case b10
//        
//    }
//    
//    case billboard(Billboard)
//    case header(Header)
//    case title(Title)
//    case body(Body)
//    
//    var font: UIFont {
//        
//        switch self {
//        case .billboard(let style):
//            
//            switch style {
//            case .b1: return .rounded(size: 64, weight: .heavy)
//            }
//            
//        case .header(let style):
//            
//            switch style {
//            case .h1: return .rounded(size: 36, weight: .heavy)
//            case .h5: return .rounded(size: 28, weight: .heavy)
//            case .h6: return .rounded(size: 22, weight: .heavy)
//            case .h10: return .rounded(size: 20, weight: .heavy)
//            case .h15: return .serif(size: 16, weight: .heavy)
//            }
//            
//        case .title(let style):
//            
//            switch style {
//            case .t1: return .rounded(size: 12, weight: .medium)
//            case .t2: return .rounded(size: 12, weight: .bold)
//            case .t4: return .rounded(size: 14, weight: .bold)
//            case .t5: return .rounded(size: 16, weight: .bold)
//            case .t6: return .rounded(size: 18, weight: .semibold)
//            case .t8: return .rounded(size: 22, weight: .semibold)
//            case .t10: return .rounded(size: 24, weight: .heavy)
//            }
//            
//        case .body(let style):
//            
//            switch style {
//            case .b1: return .rounded(size: 12, weight: .regular)
//            case .b4: return .rounded(size: 14, weight: .regular)
//            case .b5: return .rounded(size: 16, weight: .regular)
//            case .b10: return .rounded(size: 18, weight: .regular)
//            }
//        }
//        
//    }
//    
//}
//
//extension Font {
//    
//    static func appFont(_ font: Theme.FontKey) -> Font {
//        
//        let uiFont = font.font
//        return Font(uiFont)
//        
//    }
//    
//}
//
//// Modifier
//
//struct AppFontViewModifier: ViewModifier {
//    
//    var font: Theme.FontKey!
//    
//    func body(content: Content) -> some View {
//        content
//            .font(.appFont(font))
//    }
//    
//}
//
//// Short-hand View Modifier
//
//extension View {
//    
//    func appFont(with font: Theme.FontKey) -> some View {
//        modifier(AppFontViewModifier(font: font))
//    }
//    
//}
//
//extension Label {
//    
//    func appFont(with font: Theme.FontKey) -> some View {
//        modifier(AppFontViewModifier(font: font))
//    }
//    
//}
//
//extension Text {
//    
//    func appFont(with font: Theme.FontKey) -> some View {
//        modifier(AppFontViewModifier(font: font))
//    }
//    
//}
