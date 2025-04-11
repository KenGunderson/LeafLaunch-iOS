//
//  InfoView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/3/25.
//

import SwiftUI

struct InfoView: View {
    
    private let title: String
    private let titleFont: AppFont
    private let imageSource: ImageSource?
    private let foregroundStyle: ColorSource
    private let action: (() -> ())?
    
    init(title: String,
         titleFont: AppFont = AppFont.title(.t5),
         imageSource: ImageSource? = nil,
         foregroundStyle: ColorSource,
         action: (() -> ())? = nil) {
        
        self.title = title
        self.titleFont = titleFont
        self.imageSource = imageSource
        self.foregroundStyle = foregroundStyle
        self.action = action
        
    }
    
    var body: some View {
        
        HStack(spacing: DesignSystem.shared.spacing(CustomTheme.SpacingKey.custom(12))) {
            
            if let imageSource {
                
                imageSource
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: 24,
                        height: 24
                    )
                    .foregroundStyle(self.foregroundStyle.source())
                
            }
            
            Text(self.title)
                .appFont(with: self.titleFont)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(self.foregroundStyle.source())
            
            if self.action != nil {
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(
                        width: 8,
                        height: 16
                    )
                    .foregroundStyle(self.foregroundStyle.source())
                
            }
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .large)
        .frame(maxWidth: .infinity)
        .background(content: {
            
            switch self.foregroundStyle {
            case .color(let color):
                
                color
                    .color
                    .opacity(0.1)
                
            case .material(let material):
                
                AnyView(Rectangle().fill(material.material))
                    .opacity(0.1)
                
            case .linearGradient(let linearGradient):
                
                linearGradient
                    .gradient
                    .opacity(0.1)
                
            }
            
        })
        .clipShape(.rect(cornerRadius: DesignSystem.shared.radius(.small)))
        .if(action != nil) { view in
            
            view.asButton {
                self.action?()
            }
            
        }
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        VStack(spacing: 16) {
            
            InfoView(
                title: "This is the info",
                imageSource: .systemImage("lightbulb"),
                foregroundStyle: DesignSystem.shared.accent) {
                    print("Something")
                }
            
            InfoView(
                title: "This is the info that I found useful while building this app",
                imageSource: .systemImage("house"),
                foregroundStyle: .linearGradient(.init(
                    colors: [
                        .blue,
                        .mint
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
            )
            
            InfoView(
                title: "This is the info that I found useful while building this app",
                imageSource: .systemImage("info.circle"),
                foregroundStyle: .color(.purple)
            )
            
            InfoView(
                title: "This is the info that I found useful while building this app",
                foregroundStyle: .color(.red)) {
                print("Button 2")
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}
