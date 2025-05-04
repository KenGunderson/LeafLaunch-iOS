//
//  Defaults.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension Theme.Spacing {
    
    static let `default` = Theme.Spacing(
        extraSmall: 4,
        small: 8,
        small2: 12,
        medium: 16,
        medium2: 20,
        large: 24,
        extraLarge: 32
    )
    
}

extension Theme.Radius {
    
    static let `default` = Theme.Radius(
        extraSmall: 4,
        small: 8,
        small2: 12,
        medium: 16,
        medium2: 18,
        large: 24,
        extraLarge: 32
    )
    
}

extension Theme.Shadow {
    
    static let `default` = Theme.Shadow(
        
        card:
            
            Theme.DecodableShadow(
                color: Color.black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            ),
        
        subtle:
            
            Theme.DecodableShadow(
                color: Color.black.opacity(0.05),
                radius: 4,
                x: 0,
                y: 2
            ),
        
        offset:
            
            Theme.DecodableShadow(
                color: Color.black.opacity(0.2),
                radius: 10,
                x: 10,
                y: 10
            ),
        
        neon:
            
            Theme.DecodableShadow(
                color: Color.blue.opacity(0.7),
                radius: 20,
                x: 0,
                y: 0
            ),
        
        hard:
            
            Theme.DecodableShadow(
                color: Color.black.opacity(0.25),
                radius: 0,
                x: 0,
                y: 2
            ),
        
        inner:
            
            Theme.DecodableShadow(
                color: Color.black.opacity(0.3),
                radius: 4,
                x: 0,
                y: 2
            )

    )
    
}

extension Theme.Fonts {
    
    static var `default`: Theme.Fonts {
        
        return Theme.Fonts(
            BILLBOARD_B1: .rounded(size: 64, weight: .heavy),
            HEADER_H1: .rounded(size: 36, weight: .heavy),
            HEADER_H5: .rounded(size: 28, weight: .heavy),
            HEADER_H6: .rounded(size: 22, weight: .heavy),
            HEADER_H10: .rounded(size: 20, weight: .heavy),
            HEADER_H15: .serif(size: 16, weight: .heavy),
            TITLE_T1: .rounded(size: 12, weight: .medium),
            TITLE_T2: .rounded(size: 12, weight: .bold),
            TITLE_T4: .rounded(size: 14, weight: .bold),
            TITLE_T5: .rounded(size: 16, weight: .bold),
            TITLE_T6: .rounded(size: 18, weight: .semibold),
            TITLE_T8: .rounded(size: 22, weight: .semibold),
            TITLE_T10: .rounded(size: 24, weight: .heavy),
            BODY_B1: .rounded(size: 12, weight: .regular),
            BODY_B4: .rounded(size: 14, weight: .regular),
            BODY_B5: .rounded(size: 16, weight: .regular),
            BODY_B10: .rounded(size: 18, weight: .regular)
        )
        
    }
    
}
