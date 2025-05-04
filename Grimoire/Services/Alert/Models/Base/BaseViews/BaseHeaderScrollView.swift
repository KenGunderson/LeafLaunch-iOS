//
//  BaseHeaderScrollView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import SwiftUI

struct BaseHeaderScrollView<NavBarContent: View,
                            ScrollViewContent: View>: View {
    
    private let alignment: Alignment
    private let backgroundColor: Color
    private let navBarContent: NavBarContent
    private let scrollViewContent: ScrollViewContent
    
    private var horizontalPadding: Spacing = .medium
    
    public init(alignment: Alignment = .top,
                horizontalPadding: Spacing = .medium,
                backgroundColor: Color = .clear,
                @ViewBuilder navBarContent: () -> NavBarContent,
                @ViewBuilder scrollViewContent: () -> ScrollViewContent) {
        
        self.alignment = alignment
        self.backgroundColor = backgroundColor
        self.horizontalPadding = horizontalPadding
        self.navBarContent = navBarContent()
        self.scrollViewContent = scrollViewContent()
        
    }
    
    var body: some View {
        
        AppBaseView(alignment: self.alignment) {
            
            VStack(spacing: Spacing.none.value) {
                
                self.navBarContent
                    .zIndex(100)
                
                ScrollView {
                    
                    self.scrollViewContent
                        .padding(.top, .medium)
                        .padding(.horizontal, self.horizontalPadding)

                }
//                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                .background(self.backgroundColor)
                
            }
            
        }
        .navigationBarBackButtonHidden()
        .scrollIndicators(.hidden)
        
    }
    
}
