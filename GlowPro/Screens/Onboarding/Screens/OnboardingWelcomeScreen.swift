//
//  OnboardingWelcomeScreen.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/20/24.
//

import SwiftUI

struct OnboardingWelcomeScreen: GPView {
    
    @State private var shouldAnimate: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Welcome")
                .appFont(with: .BILLBOARD_1)
                .padding(.horizontal, .medium)
            
            Text("Here is the home page where you can start looking for the help you might need")
                .appFont(with: .TITLE_5)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .padding(.horizontal, .medium)
                .multilineTextAlignment(.leading)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Style.shared.accent.source())
                .frame(height: 250)
                .padding(.top, .large)
                .zIndex(-1)
                .padding(.horizontal, .medium)
            
            let text = """
            • Bananas are berries, botanically.
            • A group of flamingos.
            • Honey never spoils, lasts forever.
            • Octopuses have three hearts.
            """
            
            Text(text)
                .appFont(with: .HEADER_2)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .custom(60))
                .padding(.horizontal, .medium)
                .multilineTextAlignment(.leading)
            
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
    OnboardingWelcomeScreen()
}
