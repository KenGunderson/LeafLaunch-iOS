//
//  NavBarButton.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/12/25.
//

import SwiftUI

struct NavBarButton: View {
    
    enum Style: Hashable {
        
        case back
        case close
        case settings
        case plus
        case bell(notificationCount: Int = 0)
        
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
            .overlay(alignment: .topTrailing) {
                
                switch self.style {
                case .bell(let notificationCount):
                    
                    Text("\(notificationCount)")
                        .appFont(with: .custom(.rounded(size: 8, weight: .semibold)))
                        .frame(minWidth: 14, minHeight: 14, alignment: .center)
                        .foregroundStyle(.white)
                        .background(Rune.Style.shared.accent.source())
                        .clipShape(.circle)
                        .fixedSize(horizontal: true, vertical: false)
                        .offset(x: 4, y: -8)
                        
                    
                default: EmptyView()
                }
                
            }
        
    }
    
}

#Preview {
    
    VStack {
        
        NavBarButton(style: .back, action: {})
        NavBarButton(style: .close, action: {})
        NavBarButton(style: .settings, action: {})
        NavBarButton(style: .plus, action: {})
        NavBarButton(style: .bell(notificationCount: 2), action: {})
        
    }
    
}
