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
        case ellipsis
        case plus
        case bell(notificationCount: Int = 0)
        case pencil
        case filter(isFilled: Bool = false)
        case trash
        
        var icon: ImageSource {
            switch self {
            case .back: return .systemImage("arrow.left")
            case .close: return .systemImage("xmark")
            case .settings: return .image(.iconSetting)
            case .ellipsis: return .systemImage("ellipsis")
            case .plus: return .systemImage("plus")
            case .bell: return .image(.iconBell)
            case .pencil: return .systemImage("pencil")
            case .filter(let isFilled): return .systemImage("line.3.horizontal.decrease.circle\(isFilled ? ".fill" : "")")
            case .trash: return .systemImage("trash")
            }
        }
        
        var smallerIcon: Bool {
            switch self {
            case .close, .pencil: return true
            default: return false
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
    
        let frame: CGFloat = self.style.smallerIcon ? 16 : 20
        
        self.style.icon
            .view(renderingMode: .template)
            .scaledToFit()
            .frame(width: frame, height: frame)
            .padding(4)
            .foregroundStyle(Rune.Style.shared.textColor(.title).source())
            .asButton {
                action()
            }
            .overlay(alignment: .topTrailing) {
                
                switch self.style {
                case .bell(let notificationCount):
                    
                    if notificationCount > 0 {
                        badge(count: notificationCount)
                    }
                    
                default: EmptyView()
                }
                
            }
        
    }
    
    private func badge(count: Int) -> some View {
        
        let digitCount = max(1, String(count).count)
        
        return Text("\(count)")
            .appFont(with: .custom(.rounded(size: 10, weight: .semibold)))
            .padding(.horizontal, horizontalPadding(for: digitCount))
            .padding(.vertical, 1.3)
            .foregroundStyle(.white)
            .lineLimit(1)
            .background(Rune.Style.shared.accent.source())
            .cornerRadius(.custom(99))
            .offset(x: 0, y: -3.5)
            .fixedSize(horizontal: true, vertical: false)
        
    }
    
    private func horizontalPadding(for digits: Int) -> CGFloat {
        
        // 1 digit ≈ circle, extra digits add more width
        switch digits {
        case 1: return 4
        case 2: return 4
        default: return CGFloat(4 + (digits - 2) * 2)
        }
        
    }
    
}

#Preview {
    
    VStack {
        
        NavBarButton(style: .back, action: {})
        NavBarButton(style: .close, action: {})
        NavBarButton(style: .settings, action: {})
        NavBarButton(style: .plus, action: {})
        NavBarButton(style: .filter(isFilled: true), action: {})
        NavBarButton(style: .filter(isFilled: false), action: {})
        NavBarButton(style: .bell(notificationCount: 6), action: {})
        NavBarButton(style: .bell(notificationCount: 65), action: {})
        
    }
    
}
