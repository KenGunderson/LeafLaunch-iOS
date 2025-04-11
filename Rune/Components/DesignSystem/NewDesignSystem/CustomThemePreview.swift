//
//  NewAppShadow.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

// MARK: - Preview

fileprivate struct CustomThemePreview: View {
    
    @Environment(\.designSystem) private var theme
    
    var body: some View {
        
        VStack(spacing: theme.spacing(.medium)) {
            
            Text("Design System Theme")
                .font(theme.font(.title))
                .foregroundStyle(theme.theme.textColor.title.source())
                .contentTransition(.interpolate)
                .newAppShadow(theme.shadow(.hard))
            
            Text("Design System Theme")
                .font(theme.font(.title))
                .foregroundStyle(theme.theme.textColor.title.source())
                .contentTransition(.interpolate)
                .newAppShadow(theme.shadow(.inner))
            
            Text("Design System Theme")
                .font(theme.font(.title))
                .foregroundStyle(theme.theme.textColor.title.source())
                .contentTransition(.interpolate)
                .newAppShadow(theme.shadow(.neon))
            
            Text("Design System Theme")
                .font(theme.font(.title))
                .foregroundStyle(theme.theme.textColor.title.source())
                .contentTransition(.interpolate)
                .newAppShadow(theme.shadow(.offset))
            
            Button("Toggle Theme") {
                theme.updateTheme(.EMERALD_NOIR)
            }
            .padding(theme.spacing(.small))
            .background(theme.accent.source())
            .clipShape(.rect(cornerRadius: theme.radius(.small2)))
            .newAppShadow(theme.shadow(.subtle))
            .foregroundColor(.white)
            .contentTransition(.interpolate)
            
        }
        .padding(theme.spacing(.large))
        .background(theme.background(.primary).source())
        .clipShape(.rect(cornerRadius: theme.radius(.medium2)))
        .newAppShadow(theme.shadow(.card))
        .compositingGroup()
        .contentTransition(.interpolate)
        .animation(.easeOut(duration: 1.2), value: self.theme.theme.id)
        
    }
    
}

#Preview {
    
    CustomThemePreview()
        .environment(DesignSystem.shared)
    
}

