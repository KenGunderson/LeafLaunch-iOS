//
//  StyleSpacing.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

extension View {
    
    func padding(_ edges: Edge.Set = .all,
                 _ length: Theme.SpacingKey) -> some View {
        
        return self.padding(edges, Style.shared.spacing(length))
        
    }
    
    func padding(_ length: Theme.SpacingKey) -> some View {
        
        return self.padding(.all, Style.shared.spacing(length))
        
    }
    
}

extension EdgeInsets {
    
    init(top: Theme.SpacingKey = .none,
         left: Theme.SpacingKey = .none,
         bottom: Theme.SpacingKey = .none,
         right: Theme.SpacingKey = .none) {
        
        self.init(
            top: Style.shared.spacing(top),
            leading: Style.shared.spacing(left),
            bottom: Style.shared.spacing(bottom),
            trailing: Style.shared.spacing(right)
        )
        
    }
    
    init(spacing: Theme.SpacingKey) {
        
        self.init(
            top: Style.shared.spacing(spacing),
            leading: Style.shared.spacing(spacing),
            bottom: Style.shared.spacing(spacing),
            trailing: Style.shared.spacing(spacing)
        )
        
    }
    
    init(verticalSpacing spacing: Theme.SpacingKey) {
        
        self.init(
            top: Style.shared.spacing(spacing),
            leading: 0,
            bottom: Style.shared.spacing(spacing),
            trailing: 0
        )
        
    }
    
    init(horizontalSpacing spacing: Theme.SpacingKey) {
        
        self.init(
            top: 0,
            leading: Style.shared.spacing(spacing),
            bottom: 0,
            trailing: Style.shared.spacing(spacing)
        )
        
    }
    
}
