//
//  NewAppShadow.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

struct NewAppShadow: ViewModifier {
    
    let style: CustomTheme.DecodableShadow
    
    func body(content: Content) -> some View {
        
        content
            .shadow(
                color: self.style.color,
                radius: self.style.radius,
                x: self.style.x,
                y: self.style.y
            )
        
    }
    
}
