//
//  AppBaseView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import SwiftUI

struct AppBaseView<Content>: View where Content: View {
    
    private let horizontalPadding: CustomTheme.SpacingKey
    private let content: Content
    private let alignment: Alignment
    private let backgroundStyle: ColorSource

    public init(
        alignment: Alignment = .center,
        horizontalPadding: CustomTheme.SpacingKey = .none,
        backgroundStyle: ColorSource = DesignSystem.shared.background(.primary),
        @ViewBuilder content: () -> Content) {
            
            self.alignment = alignment
            self.horizontalPadding = horizontalPadding
            self.backgroundStyle = backgroundStyle
            self.content = content()
            
        }
    
    var body : some View {
        
        ZStack(alignment: self.alignment) {
            
            self.backgroundStyle
                .view()
                .ignoresSafeArea()
            
            content
                .padding(.horizontal, self.horizontalPadding)
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        
    }
    
}
