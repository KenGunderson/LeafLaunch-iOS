//
//  OnboardingFeaturesScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/2/25.
//

import SwiftUI

struct OnboardingFeaturesScreen: GPView {
    
    @State private var shouldAnimate: Bool = false
    
    private let title: String
    private let message: String
    
    init(title: String,
         message: String) {
        
        self.title = title
        self.message = message
        
    }
    
    var body: some View {
        
        VStack(spacing: Style.shared.spacing(.none)) {
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Style.shared.accent.source())
                .frame(height: 360)
                .padding([.top], .large)
                .zIndex(-1)
            
            Text(self.title)
                .appFont(with: .HEADER_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .padding(.top, .extraLarge)
            
            Text(self.message)
                .appFont(with: .BODY_3)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .padding(.top, .small)
                .multilineTextAlignment(.center)

        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, .large)
        .onAppear {
            
            withAnimation(.smooth(duration: 0.6, extraBounce: 0.2).delay(0.3)) {
                self.shouldAnimate = true
            }
            
        }
        .onDisappear {
            
            withAnimation(.smooth(duration: 0.6, extraBounce: 0.2).delay(0.3)) {
                self.shouldAnimate = false
            }
            
        }
        .opacity(self.shouldAnimate ? 1 : 0)
        .offset(y: self.shouldAnimate ? 0 : 200)
        .padding(.top, OnboardingScreen.headerHeight)
        
    }
    
}

#Preview {
    
    OnboardingFeaturesScreen(
        title: "Capture Progress",
        message: "Use our built-in camera to take before and after photos right in the treatment room"
    )

}
