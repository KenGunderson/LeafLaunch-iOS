//
//  TokenView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 11/13/24.
//

import SwiftUI

struct TokenView: View {
    
    private let text: String
    private let titleFont: AppFont
    private let foregroundStyle: ColorSource
    private let backgroundStyle: ColorSource
    private let horizontalPadding: Spacing
    private let verticalPadding: Spacing
    
    init(text: String,
         titleFont: AppFont = .title(.t4),
         foregroundStyle: ColorSource = .color(.white),
         backgroundStyle: ColorSource = .color(ThemeManager.shared.background(.quad)),
         horizontalPadding: Spacing = .custom(12),
         verticalPadding: Spacing = .xSmall) {
        
        self.text = text
        self.titleFont = titleFont
        self.foregroundStyle = foregroundStyle
        self.backgroundStyle = backgroundStyle
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        
    }
    
    var body: some View {
    
        Text(self.text)
            .appFont(with: self.titleFont)
            .foregroundStyle(self.foregroundStyle.source())
            .padding(.horizontal, self.horizontalPadding.value)
            .padding(.vertical, self.verticalPadding.value)
            .background(self.backgroundStyle.source())
            .clipShape(.capsule)
        
    }
    
}

#Preview {
    
    let backgroundGradient = LinearGradient.init(
        colors: [.blackedGray, .blackedGray],
        startPoint: .top,
        endPoint: .bottom
    )
    
    AppBaseView(backgroundStyle: .linearGradient(backgroundGradient)) {
        
        VStack(spacing: Spacing.large.value) {
            
            TokenView(
                text: "Simple Token"
            )
            .asButton {
                print("Pressing Simple Token")
            }

            TokenView(
                text: "Simple Padded Token",
                horizontalPadding: .xLarge,
                verticalPadding: .medium
            )
            
            TokenView(
                text: "Text Gradient Token",
                foregroundStyle: .linearGradient(.init(
                    colors: [.indigo, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
            )
            
            TokenView(
                text: "Background Gradient Token",
                foregroundStyle: .color(.white),
                backgroundStyle: .linearGradient(.init(
                    colors: [.mint, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
            )
            
            TokenView(
                text: "Blur Material Token",
                foregroundStyle: .color(.black),
                backgroundStyle: .material(.regular)
            )
            
        }
        
    }
    
}
