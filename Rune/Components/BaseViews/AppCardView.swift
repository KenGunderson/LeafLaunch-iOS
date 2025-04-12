//
//  BaseCardView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import SwiftUI

struct AppCardView<Content>: View where Content: View {

    private let verticalPadding: Theme.SpacingKey
    private let horizontalPadding: Theme.SpacingKey
    private let backgroundStyle: ColorSource
    private let cornerRadius: Theme.RadiusKey
    private let content: Content
    
    public init(verticalPadding: Theme.SpacingKey = .medium,
                horizontalPadding: Theme.SpacingKey = .medium,
                backgroundStyle: ColorSource = Style.shared.background(.secondary),
                cornerRadius: Theme.RadiusKey = .small2,
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
        .foregroundStyle(Style.shared.accent.source())
        
    }
    .padding(.horizontal, 32)
    
}
