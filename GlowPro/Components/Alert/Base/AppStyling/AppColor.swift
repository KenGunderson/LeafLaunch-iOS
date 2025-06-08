//
//  AppColor.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/2/24.
//

import SwiftUI

struct AppColor {
    
    enum BackgroundStyle {
        
        case primary
        case secondary
        case tertiary
        case quad
        
    }
    
    enum TextStyle {
        
        case title
        case body
        
    }
    
    enum Gradient {
        
        case background
        case primary
        
    }
    
    // PRIMARY
    
    /// #3DC08D
    static var brandGreen: Color {
        return Color("brand_green")
    }
    
    /// #008A5B
    static var brandGreen2: Color {
        return Color("brand_green_2")
    }
    
    /// #009DF7
    static var brandBlue: Color {
        return Color("brand_blue")
    }
    
    /// #388ADA
    static var brandBlue2: Color {
        return Color("brand_blue_2")
    }
    
    /// #4B5DBA
    static var brandIndigo: Color {
        return Color(hex: "4B5DBA")
    }

    /// #3A4D91
    static var brandIndigo2: Color {
        return Color(hex: "3A4D91")
    }

    /// #4BC0B0
    static var brandMint: Color {
        return Color(hex: "4BC0B0")
    }

    /// #3A8F89
    static var brandMint2: Color {
        return Color(hex: "3A8F89")
    }

    /// #BA5D3D
    static var brandOrange: Color {
        return Color(hex: "BA5D3D")
    }

    /// #8F472A
    static var brandOrange2: Color {
        return Color(hex: "8F472A")
    }
    
    /// #4C6274
    static var brandGray: Color {
        return Color("brand_gray")
    }
    
    // BACKGROUND
    
    /// (OLD #EEFBFF) (NEW #FAFEFF)
    static var background: Color {
        return Color("background_1")
    }
    
    /// #FFFFFF
    static var background2: Color {
        return Color("background_2")
    }
    
    /// #C1DCF5
    static var background3: Color {
        return Color("background_3")
    }
    
    /// #EDF6FF
    static var background4: Color {
        return Color("background_4")
    }
    
    static func background(_ backgroundStyle: BackgroundStyle) -> Color {
        
        switch backgroundStyle {
        case .primary: return Color(light: Self.background, dark: Self.background)
        case .secondary: return Color(light: Self.background2, dark: Self.background2)
        case .tertiary: return Color(light: Self.background3, dark: Self.background3)
        case .quad: return Color(light: Self.background4, dark: Self.background4)
        }
        
    }
    
    static func textStyle(_ textStyle: TextStyle) -> Color {

        switch textStyle {
        case .title: return .black
        case .body: return Self.brandGray
        }

    }
    
//    static func gradient(_ gradient: AppColor.Gradient) -> LinearGradient {
//        
//        switch gradient {
//        case .background: return
//            
//            LinearGradient(
//                colors: [Self.brandGray],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            
//        case .primary: return
//            
//            LinearGradient(
//                colors: [AppColor.brandGreen, .brandGreen2],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            
//        }
//        
//    }
    
}
