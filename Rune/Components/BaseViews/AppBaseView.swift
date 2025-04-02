//
//  AppBaseView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import SwiftUI

struct AppBaseView<Content>: View where Content: View {
    
    private let horizontalPadding: Spacing
    private let content: Content
    private let alignment: Alignment
    private let backgroundStyle: AppBackgroundStyle

    public init(
        alignment: Alignment = .center,
        horizontalPadding: Spacing = .none,
        backgroundStyle: AppBackgroundStyle = .color(ThemeManager.shared.background(.primary)),
        @ViewBuilder content: () -> Content) {
            
            self.alignment = alignment
            self.horizontalPadding = horizontalPadding
            self.backgroundStyle = backgroundStyle
            self.content = content()
            
        }
    
    var body : some View {
        
        ZStack(alignment: self.alignment) {
            
            self.backgroundStyle
                .viewStyle()
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
