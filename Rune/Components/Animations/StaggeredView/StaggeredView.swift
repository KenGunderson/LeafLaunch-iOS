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
        delay: 0.02,
        blurRadius: 2,
        offset: .init(width: 0, height: 0),
        scale: 0.5,
        scaleAnchor: .center,
        disappearInSameDirection: false,
        noDisappearAnimation: false
    )
        
    var body: some View {
        
        AppHeaderScrollView {
            
            CommonButton(
                title: "Toggle View",
                titleColor: Style.shared.textColor(.title),
                backgroundStyle: Style.shared.accent
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
                            .fill(Style.shared.background(.quaternary).source())
                            .frame(height: 150)
                            .padding(.horizontal, Style.shared.spacing(.medium))
                            .padding(.vertical, Style.shared.spacing(.small))
                        
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
