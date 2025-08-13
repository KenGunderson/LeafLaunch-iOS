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
        case bell
        
        var systemName: String {
            switch self {
            case .back: return "arrow.left"
            case .close: return "xmark"
            case .settings: return "gear"
            case .plus: return "plus"
            case .bell: return "bell"
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
        
        Image(systemName: self.style.systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18)
            .asButton {
                action()
            }
        
    }
    
}

#Preview {
    
    VStack {
        
        NavBarButton(style: .back, action: {})
        NavBarButton(style: .close, action: {})
        NavBarButton(style: .settings, action: {})
        NavBarButton(style: .plus, action: {})
        
    }
    
}
