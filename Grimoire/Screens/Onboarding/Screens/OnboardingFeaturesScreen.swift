//
//  OnboardingFeaturesScreen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/2/25.
//

import SwiftUI

struct OnboardingFeaturesScreen: GPView {
    
    @State private var shouldAnimate: Bool = false
    
    private let onboardingPage: OnboardingPage
    
    init(onboardingPage: OnboardingPage) {
        self.onboardingPage = onboardingPage
    }
    
    var body: some View {
        
        VStack(spacing: Style.shared.spacing(.none)) {
            
            self.onboardingPage
                .illustration
                .view(renderingMode: .original)
                .scaledToFit()
                .frame(height: Constants.Runtime.deviceHeight * 0.53)
                .padding([.top], .large)
                .zIndex(-1)
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                Text(self.onboardingPage.title)
                    .appFont(with: .HEADER_3)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .padding(.horizontal, .extraLarge)
                
                Text(self.onboardingPage.message)
                    .appFont(with: .BODY_4)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .extraLarge)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, .large)

        }
        .frame(maxHeight: .infinity, alignment: .top)
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
    OnboardingFeaturesScreen(onboardingPage: .businessSetup)
}
