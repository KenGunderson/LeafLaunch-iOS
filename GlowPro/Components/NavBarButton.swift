//
//  NavBarButton.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/12/25.
//

import SwiftUI

struct NavBarButton: View {
    
    enum Style {
        
        case back
        case close
        case settings
        case plus
        
        var systemName: String {
            switch self {
            case .back: return "arrow.left"
            case .close: return "xmark"
            case .settings: return "gear"
            case .plus: return "plus"
            }
        }
        
    }
    
    private let style: Style
    private let action: () -> Void
    
    init(style: Style,
         action: @escaping () -> Void) {
        
        self.style = style
        self.action = action
        
    }
    
    var body: some View {
        
        CircularIconView(
            foregroundColor: .color(.black),
            backgroundColor: .color(.clear),
            imageSource: .systemImage(self.style.systemName),
            size: 32
        )
        .asButton {
            action()
        }
        
    }
    
}
