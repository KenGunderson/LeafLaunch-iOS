//
//  StaggeredView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/26/25.
//

import SwiftUI

struct StaggeredView<Content: View>: View {
    
    @ViewBuilder var content: Content
    var config: StaggeredConfig
    
    init(config: StaggeredConfig,
         @ViewBuilder content: () -> Content) {
        
        self.content = content()
        self.config = config
        
    }
    
    var body: some View {
        
        Group(subviews: content) { collection in
            
            ForEach(collection.indices, id: \.self) { index in
                                
                collection[index]
                    .transition(CustomStaggeredTransition(index: index, config: config))
                
            }
            
        }
        
    }
    
}

struct StaggeredTestView: View {
    
    @State var showView: Bool = false

    let config = StaggeredConfig(
        delay: 0,
        blurRadius: 2,
        offset: .init(width: 200, height: 0),
        scale: 1,
        scaleAnchor: .center,
        disappearInSameDirection: true
    )
        
    var body: some View {
        
        AppHeaderScrollView {
            
            CommonButton(
                title: "Toggle View",
                titleColor: .color(ThemeManager.shared.textColor(.title)),
                backgroundStyle: .color(ThemeManager.shared.accentColor())
            ) {
                
                showView
                    .toggle()
                
            }
            .padding(.horizontal, .large)
            
        } scrollViewContent: {
            
            StaggeredView(config: config) {
                
                if showView {
                    
                    ForEach(1...6, id: \.self) { _ in
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(ThemeManager.shared.background(.quad))
                            .frame(height: 150)
                            .padding(.horizontal, Spacing.medium.value)
                            .padding(.vertical, Spacing.small.value)
                        
                    }
                    
                }
                
                // When you have no frame animations could be weird
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            
        }
        
        
    }
    
}

#Preview {
    
    StaggeredTestView()
    
}
