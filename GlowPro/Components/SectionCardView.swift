//
//  SectionCardView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/18/25.
//

import SwiftUI

struct SectionCardView<Content: View>: View {
    
    private let title: String
    private let subtitle: String?
    private let icon: ImageSource
    private let color: ColorSource
    private let headerActionTitle: String?
    private let headerAction: (() -> Void)?
    private let content: () -> Content
    
    init(title: String,
         subtitle: String? = nil,
         icon: ImageSource,
         color: ColorSource,
         headerActionTitle: String? = nil,
         headerAction: (() -> Void)? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.headerActionTitle = headerActionTitle
        self.headerAction = headerAction
        self.content = content
        
    }
    
    var body: some View {
        
        sectionCardView(color: self.color) {
            
            sectionCardHeader()
            
        } content: {
            
            self.content()
            
        }
        
    }
    
    @ViewBuilder
    private func sectionCardHeader() -> some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                
                self.icon
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .padding(8)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.white)
                    .background(self.color.source())
                    .clipShape(.circle)
                
                Text(self.title)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let headerActionTitle,
                   let headerAction {
                    
                    TokenView(
                        text: headerActionTitle,
                        foregroundStyle: color,
                        backgroundStyle: .color(.clear),
                        horizontalPadding: .medium,
                        verticalPadding: .custom(6),
                    )
                    .appBorder(
                        cornerRadius: .extraLarge,
                        color: color,
                        lineWidth: 1.5
                    )
                    .asButton {
                        headerAction()
                    }
                    
                }
                
            }
            
            if let subtitle = self.subtitle {
                
                Text(subtitle)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
        }
        
    }

    @ViewBuilder
    private func sectionCardView(color: ColorSource,
                                 header: @escaping () -> some View,
                                 content: @escaping () -> some View) -> some View {
        
        AppCardView {
            
            VStack(spacing: Style.shared.spacing(.small2)) {
                
                header()
                content()
                
            }
            
        }
        .appBorder(
            cornerRadius: .small2,
            color: .color(self.color.asColor!.opacity(0.55)),
            lineWidth: 2.5
        )
        
    }
    
}
