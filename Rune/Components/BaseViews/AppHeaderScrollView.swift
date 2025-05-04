//
//  AppHeaderScrollView.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import SwiftUI

struct AppHeaderScrollView<NavBarContent: View,
                           ScrollViewContent: View>: View {
    
    @Binding private var scrollOffset: CGFloat
    
    private let alignment: Alignment
    private let backgroundStyle: ColorSource
    private let isScrollTrackingEnabled: Bool
    private let navBarContent: NavBarContent
    private let scrollViewContent: ScrollViewContent
    
    private var horizontalPadding: Theme.SpacingKey = .medium
    
    public init(alignment: Alignment = .top,
                horizontalPadding: Theme.SpacingKey = .medium,
                backgroundStyle: ColorSource = .color(.clear),
                scrollOffset: Binding<CGFloat>? = nil,
                @ViewBuilder navBarContent: () -> NavBarContent,
                @ViewBuilder scrollViewContent: () -> ScrollViewContent) {
        
        self.alignment = alignment
        self.backgroundStyle = backgroundStyle
        self.horizontalPadding = horizontalPadding
        
        self.isScrollTrackingEnabled = scrollOffset != nil
        self._scrollOffset = scrollOffset ?? .constant(0)
        
        self.navBarContent = navBarContent()
        self.scrollViewContent = scrollViewContent()
        
    }
    
    var body: some View {
        
        AppBaseView(alignment: self.alignment) {
            
            VStack(spacing: Style.shared.spacing(.none)) {
                
                self.navBarContent
                    .zIndex(100)
                
                ScrollView {
                    
                    self.scrollViewContent
                        .padding(.top, .medium)
                        .padding(.horizontal, self.horizontalPadding)

                }
//                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                .background(self.backgroundStyle.source())
                .if(self.isScrollTrackingEnabled) { view in
                    
                    view.onScrollGeometryChange(for: CGFloat.self) { geo in
                        return geo.contentOffset.y
                    } action: { oldValue, newValue in
                        self.scrollOffset = newValue
                    }
                    
                }
                
            }
            
        }
        .navigationBarBackButtonHidden()
        .scrollIndicators(.hidden)
        
    }
    
}
