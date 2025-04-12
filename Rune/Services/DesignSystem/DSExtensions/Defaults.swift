//
//  Defaults.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension CustomTheme.Spacing {
    
    static let `default` = CustomTheme.Spacing(
        extraSmall: 4,
        small: 8,
        small2: 12,
        medium: 16,
        medium2: 20,
        large: 24,
        extraLarge: 32
    )
    
}

extension CustomTheme.Radius {
    
    static let `default` = CustomTheme.Radius(
        extraSmall: 4,
        small: 8,
        small2: 12,
        medium: 16,
        medium2: 18,
        large: 24,
        extraLarge: 32
    )
    
}

extension CustomTheme.Shadow {
    
    static let `default` = CustomTheme.Shadow(
        
        card:
            
            CustomTheme.DecodableShadow(
                color: Color.black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            ),
        
        subtle:
            
            CustomTheme.DecodableShadow(
                color: Color.black.opacity(0.05),
                radius: 4,
                x: 0,
                y: 2
            ),
        
        offset:
            
            CustomTheme.DecodableShadow(
                color: Color.black.opacity(0.2),
                radius: 10,
                x: 10,
                y: 10
            ),
        
        neon:
            
            CustomTheme.DecodableShadow(
                color: Color.blue.opacity(0.7),
                radius: 20,
                x: 0,
                y: 0
            ),
        
        hard:
            
            CustomTheme.DecodableShadow(
                color: Color.black.opacity(0.25),
                radius: 0,
                x: 0,
                y: 2
            ),
        
        inner:
            
            CustomTheme.DecodableShadow(
                color: Color.black.opacity(0.3),
                radius: 4,
                x: 0,
                y: 2
            )

    )
    
}
