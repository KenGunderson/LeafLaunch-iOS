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
    private let image: Image?
    private let foregroundStyle: ColorSource
    private let action: (() -> ())?
    
    init(title: String,
         titleFont: AppFont = AppFont.title(.t5),
         image: Image? = nil,
         foregroundStyle: ColorSource,
         action: (() -> ())? = nil) {
        
        self.title = title
        self.titleFont = titleFont
        self.image = image
        self.foregroundStyle = foregroundStyle
        self.action = action
        
    }
    
    var body: some View {
        
        HStack(spacing: Spacing.custom(12).value) {
            
            if let image {
                
                image
                    .resizable()
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
        .clipShape(.rect(cornerRadius: CornerRadius.small.value))
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
                image: .init(systemName: "lightbulb"),
                foregroundStyle: .color(ThemeManager.shared.accentColor())) {
                    print("Something")
                }
            
            InfoView(
                title: "This is the info that I found useful while building this app",
                image: .init(systemName: "house"),
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
                image: .init(systemName: "info.circle"),
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
