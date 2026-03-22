//
//  EmptyStateViewModifier.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/17/25.
//

import SwiftUI

public struct EmptyStateOverlayModifier: ViewModifier {
    
    let shouldShow: Bool
    
    let config: EmptyStateConfig
    
    let transition: AnyTransition
    let animation: Animation?
    
    public func body(content: Content) -> some View {
        
        content
            .overlay {
                
                Group {
                    
                    if self.shouldShow {
                        
                        EmptyStateView(config: self.config)
                            .transition(self.transition)
                        
                    }
                    
                }
                .animation(self.animation, value: self.shouldShow)
                
            }
        
    }
    
}

extension View {
    
    /// Adds a reusable empty state overlay that animates in/out.
    func emptyStateOverlay(shouldShow: Bool,
                           config: EmptyStateConfig,
                           transition: AnyTransition = .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity.animation(.spring(duration: 0.15))
                           ),
                           animation: Animation? = .bouncy.delay(0.3)) -> some View {
        
        modifier(
            EmptyStateOverlayModifier(
                shouldShow: shouldShow,
                config: config,
                transition: transition,
                animation: animation
            )
        )
        
    }
    
}

