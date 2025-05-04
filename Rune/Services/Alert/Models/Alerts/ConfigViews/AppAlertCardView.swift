//
//  AppAlertCardVikew.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/6/24.
//

import SwiftUI

struct AppAlertCardView: View {
    
    @State private var dragOffset: CGSize = .zero
    @State private var cardSize: CGSize = .zero
    
    let config: AppCardConfig
    let onDismiss: () -> Void
    
    var body: some View {
        
        self.config.viewBuilder(self.onDismiss)
            .frame(maxWidth: .infinity)
        
        // Card Content Insets
        
            .padding(.top, self.config.contentCardInset.top)
            .padding(.leading, self.config.contentCardInset.left)
            .padding(.trailing, self.config.contentCardInset.right)
            .padding(.bottom, self.config.contentCardInset.bottom)
        
        // Background
        
            .background(self.config.cardBackgroundColor.source())
            .clipShape(.rect(cornerRadius: self.config.cornerRadius))
        
        // Background Card Insets
        
            .padding(.top, self.config.backgroundCardInset.top)
            .padding(.leading, self.config.backgroundCardInset.left)
            .padding(.trailing, self.config.backgroundCardInset.right)
            .padding(.bottom, self.config.backgroundCardInset.bottom)
        
            .appShadow()
        
        // Card Size
        
            .onGeometryChange(for: CGSize.self, of: { geo in
                return geo.size
            }, action: { newValue in
                self.cardSize = newValue
            })
        
            .offset(y: self.dragOffset.height)
        
        // Drag Gesture
        
            .gesture(
                DragGesture()
                    .onChanged { value in
                        
                        handleDragOffset(
                            value.translation,
                            hasEnded: false
                        )
                        
                    }
                    .onEnded { value in
                        
                        handleDragOffset(
                            value.translation,
                            hasEnded: true
                        )
                        
                    }
            )
        
    }
    
    private func handleDragOffset(_ offset: CGSize,
                                  hasEnded: Bool) {
        
        guard self.config.shouldDismissOnDrag else { return }
    
        if offset.height < 0 {
            return
        }
        
        // Calculate 10% of screen height
        let tenPercentScreenHeight = UIScreen.main.bounds.height * 0.1
        
        // Calculate 65% of screen height
        let cardSizeMultiplier = self.cardSize.height * 0.65
        
        // Use the larger of cardSize.height or 10% of screen height
        let dismissThreshold = max(cardSizeMultiplier, tenPercentScreenHeight)
        
        if offset.height > dismissThreshold && hasEnded {
                    
            withAnimation(.linear(duration: 0.3)) {
                
                self.dragOffset = offset
                onDismiss()
                
            }
            
            return
            
        }
        
        withAnimation(.linear(duration: 0.3)) {
            
            if hasEnded {
                self.dragOffset = .zero
            } else {
                self.dragOffset = offset
            }
            
        }
        
    }
    
}
