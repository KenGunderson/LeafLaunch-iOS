//
//  StyleCornerRadius.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/11/25.
//

import SwiftUI

extension View {
    
    func cornerRadius(_ cornerRadius: Theme.RadiusKey) -> some View {
        
        self
            .clipShape(RoundedRectangle(
                cornerRadius: Style.shared.radius(cornerRadius),
                style: .continuous
            ))
        
    }
    
}

