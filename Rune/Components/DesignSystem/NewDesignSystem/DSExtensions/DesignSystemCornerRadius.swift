//
//  DesignSystemCornerRadius.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension View {
    
    func cornerRadius(_ cornerRadius: CustomTheme.RadiusKey) -> some View {
        
        self
            .clipShape(RoundedRectangle(
                cornerRadius: DesignSystem.shared.radius(cornerRadius),
                style: .continuous
            ))
        
    }
    
}

