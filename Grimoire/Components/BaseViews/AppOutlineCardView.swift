//
//  AppOutlineCardView.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 11/19/24.
//

import SwiftUI

struct AppOutlineCardView<Content>: View where Content: View {
    
    private let verticalPadding: Theme.SpacingKey
    private let horizontalPadding: Theme.SpacingKey
    private let backgroundStyle: ColorSource
    private let outlineColor: ColorSource
    private let outlineWidth: CGFloat
    private let cornerRadius: Theme.RadiusKey
    private let content: Content
    
    public init(verticalPadding: Theme.SpacingKey = .medium,
                horizontalPadding: Theme.SpacingKey = .medium,
                backgroundStyle: ColorSource = .color(.clear),
                outlineColor: ColorSource = Style.shared.background(.tertiary),
                outlineWidth: CGFloat = 2,
                cornerRadius: Theme.RadiusKey = .small2,
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
            
            RoundedRectangle(cornerRadius: Style.shared.radius(self.cornerRadius))
                .fill(self.backgroundStyle.source())
            
        }
        .background {
            
            RoundedRectangle(cornerRadius: Style.shared.radius(self.cornerRadius))
                .stroke(
                    self.outlineColor.source(),
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
        .foregroundStyle(Style.shared.accent.source())
        
    }
    .padding(.horizontal, 32)
    
}
