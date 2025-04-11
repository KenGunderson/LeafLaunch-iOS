//
//  BaseCardView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import SwiftUI

struct AppCardView<Content>: View where Content: View {

    private let verticalPadding: CustomTheme.SpacingKey
    private let horizontalPadding: CustomTheme.SpacingKey
    private let backgroundStyle: ColorSource
    private let cornerRadius: CornerRadius
    private let content: Content
    
    public init(verticalPadding: CustomTheme.SpacingKey = .medium,
                horizontalPadding: CustomTheme.SpacingKey = .medium,
                backgroundStyle: ColorSource = DesignSystem.shared.background(.secondary),
                cornerRadius: CornerRadius = .small2,
                @ViewBuilder content: () -> Content) {
        
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.backgroundStyle = backgroundStyle
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
        .background(self.backgroundStyle.source())
        .cornerRadius(self.cornerRadius)
        .appShadow()
        
    }
    
}

#Preview {
    
    AppCardView {
        
        HStack {
            
            Label(
                "Person",
                systemImage: "person.fill"
            )
            
            Spacer(minLength: 0)
            
            Image(systemName: "chevron.right")
            
        }
        .foregroundStyle(DesignSystem.shared.accent.source())
        
    }
    .padding(.horizontal, 32)
    
}
