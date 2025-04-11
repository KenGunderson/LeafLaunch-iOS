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
    private let horizontalPadding: CustomTheme.SpacingKey
    private let verticalPadding: CustomTheme.SpacingKey
    
    init(text: String,
         titleFont: AppFont = .title(.t4),
         foregroundStyle: ColorSource = .color(.white),
         backgroundStyle: ColorSource = DesignSystem.shared.background(.quaternary),
         horizontalPadding: CustomTheme.SpacingKey = .custom(12),
         verticalPadding: CustomTheme.SpacingKey = .extraSmall) {
        
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
            .padding(.horizontal, DesignSystem.shared.spacing(horizontalPadding))
            .padding(.vertical, DesignSystem.shared.spacing(verticalPadding))
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
        
        VStack(spacing: DesignSystem.shared.spacing(.large)) {
            
            TokenView(
                text: "Simple Token"
            )
            .asButton {
                print("Pressing Simple Token")
            }

            TokenView(
                text: "Simple Padded Token",
                horizontalPadding: .extraLarge,
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
