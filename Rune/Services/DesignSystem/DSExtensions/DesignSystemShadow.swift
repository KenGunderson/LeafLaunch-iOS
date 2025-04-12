//
//  NewAppShadow.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

struct DesignSystemShadow: ViewModifier {
    
    let style: CustomTheme.ShadowKey
    
    func body(content: Content) -> some View {
        
        let shadow = DesignSystem.shared.shadow(style)
        
        content
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
        
    }
    
}

extension View {
    
    @ViewBuilder
    func appShadow(_ shadow: CustomTheme.ShadowKey = .card) -> some View {
        self.modifier(DesignSystemShadow(style: shadow))
    }
    
}
