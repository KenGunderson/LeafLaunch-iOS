//
//  Spacing.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

extension View {
    
    func padding(_ edges: Edge.Set = .all,
                 _ length: CustomTheme.SpacingKey) -> some View {
        
        return self.padding(edges, DesignSystem.shared.spacing(length))
        
    }
    
    func padding(_ length: CustomTheme.SpacingKey) -> some View {
        
        return self.padding(.all, DesignSystem.shared.spacing(length))
        
    }
    
}

extension EdgeInsets {
    
    init(top: CustomTheme.SpacingKey = .none,
         left: CustomTheme.SpacingKey = .none,
         bottom: CustomTheme.SpacingKey = .none,
         right: CustomTheme.SpacingKey = .none) {
        
        self.init(
            top: DesignSystem.shared.spacing(top),
            leading: DesignSystem.shared.spacing(left),
            bottom: DesignSystem.shared.spacing(bottom),
            trailing: DesignSystem.shared.spacing(right)
        )
        
    }
    
    init(spacing: CustomTheme.SpacingKey) {
        
        self.init(
            top: DesignSystem.shared.spacing(spacing),
            leading: DesignSystem.shared.spacing(spacing),
            bottom: DesignSystem.shared.spacing(spacing),
            trailing: DesignSystem.shared.spacing(spacing)
        )
        
    }
    
    init(verticalSpacing spacing: CustomTheme.SpacingKey) {
        
        self.init(
            top: DesignSystem.shared.spacing(spacing),
            leading: 0,
            bottom: DesignSystem.shared.spacing(spacing),
            trailing: 0
        )
        
    }
    
    init(horizontalSpacing spacing: CustomTheme.SpacingKey) {
        
        self.init(
            top: 0,
            leading: DesignSystem.shared.spacing(spacing),
            bottom: 0,
            trailing: DesignSystem.shared.spacing(spacing)
        )
        
    }
    
}
