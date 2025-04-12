//
//  StyleSystemShadow.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

struct StyleSystemShadow: ViewModifier {
    
    let style: Theme.ShadowKey
    
    func body(content: Content) -> some View {
        
        let shadow = Style.shared.shadow(style)
        
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
    func appShadow(_ shadow: Theme.ShadowKey = .card) -> some View {
        self.modifier(StyleSystemShadow(style: shadow))
    }
    
}
