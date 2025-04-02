//
//  AppOutlineCardView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 11/19/24.
//

import SwiftUI

struct AppOutlineCardView<Content>: View where Content: View {
    
    private let verticalPadding: Spacing
    private let horizontalPadding: Spacing
    private let backgroundStyle: AppBackgroundStyle
    private let outlineColor: Color
    private let outlineWidth: CGFloat
    private let cornerRadius: CornerRadius
    private let content: Content
    
    public init(verticalPadding: Spacing = .medium,
                horizontalPadding: Spacing = .medium,
                backgroundStyle: AppBackgroundStyle = .color(.clear),
                outlineColor: Color = ThemeManager.shared.background(.tertiary),
                outlineWidth: CGFloat = 2,
                cornerRadius: CornerRadius = .small2,
                @ViewBuilder content: () -> Content) {
        
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.backgroundStyle = backgroundStyle
        self.outlineColor = outlineColor
        self.outlineWidth = outlineWidth
        self.cornerRadius = cornerRadius
        self.content = content()
        
    }
    
    var body : some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 0) {
                
                self.content
                    .padding(.vertical, self.verticalPadding)
                    .padding(.horizontal, self.horizontalPadding)
                
                Spacer(minLength: 0)
                
            }
            
        }
        .background {
            
            RoundedRectangle(cornerRadius: self.cornerRadius.value)
                .fill(self.backgroundStyle.backgroundStyle())
            
        }
        .background {
            
            RoundedRectangle(cornerRadius: self.cornerRadius.value)
                .stroke(
                    self.outlineColor,
                    lineWidth: self.outlineWidth
                )
            
        }
        .background(.backgroundTappable)
        
    }
    
}

#Preview {
    
    AppOutlineCardView {
        
        HStack {
            
            Label(
                "Person",
                systemImage: "person.fill"
            )
            
            Spacer(minLength: 0)
            
            Image(systemName: "chevron.right")
            
        }
        .foregroundStyle(ThemeManager.shared.accentColor())
        
    }
    .padding(.horizontal, 32)
    
}
