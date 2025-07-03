//
//  OnboardingWelcomePage.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/20/24.
//

import SwiftUI

struct OnboardingWelcomePage: View {
    
    @State private var shouldAnimate: Bool = false
    
    let onAppear: () -> Void
    let onDisappear: () -> Void
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Welcome")
                .appFont(with: .BILLBOARD_B1)
                .padding(.horizontal, .large)
                .opacity(self.shouldAnimate ? 1 : 0)
                .offset(y: self.shouldAnimate ? 0 : -250)
            
            Text("Here is the home page where you can start looking for the help you might need")
                .appFont(with: .TITLE_T6)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .padding(.horizontal, .large)
                .multilineTextAlignment(.leading)
                .opacity(self.shouldAnimate ? 1 : 0)
                .offset(y: self.shouldAnimate ? 0 : -250)
            
            Rectangle()
                .fill(Style.shared.accent.source())
                .frame(height: 250)
                .clipShape(.circle)
                .opacity(self.shouldAnimate ? 1 : 0)
                .offset(y: self.shouldAnimate ? 0 : -250)
                .padding(.top, .large)
                .zIndex(-1)
            //                .ignoresSafeArea()
            
            let text = """
            • Bananas are berries, botanically.
            • A group of flamingos.
            • Honey never spoils, lasts forever.
            • Octopuses have three hearts.
            """
            
            Text(text)
                .appFont(with: .HEADER_H10)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .custom(60))
                .padding(.horizontal, .large)
                .opacity(self.shouldAnimate ? 1 : 0)
                .offset(y: self.shouldAnimate ? 0 : 500)
                .multilineTextAlignment(.leading)
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            
            withAnimation(.smooth(duration: 0.6, extraBounce: 0.3)) {
                self.shouldAnimate = true
            }
            
        }
        .onAppear(perform: onAppear)
        .onDisappear {
            
            withAnimation(.smooth(duration: 0.6, extraBounce: 0.3)) {
                self.shouldAnimate = false
            }
            
            onDisappear()
            
        }
        
    }
    
}

#Preview {
    
    OnboardingWelcomePage {
        print("On Appear")
    } onDisappear: {
        print("On Disappear")
    }

}
