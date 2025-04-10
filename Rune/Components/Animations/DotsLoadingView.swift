//
//  DotsLoadingView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/9/25.
//

import SwiftUI

struct DotsAnimationView: View {
    
    var shouldAnimate: Bool = true
    var foregroundColor: ColorSource = .color(ThemeManager.shared.accentColor())
    
    func animation(index: Int) -> Animation {
        
        self.shouldAnimate
        ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true).delay(Double(index) * 0.2)
        : Animation.easeInOut(duration: 0.5)
        
    }

    var body: some View {
        
        HStack {
            
            ForEach(0..<3) { index in
                
                Circle()
                    .fill(self.foregroundColor.source())
                    .offset(y: self.shouldAnimate ? -24 : 0)
                    .animation(
                        animation(index: index),
                        value: self.shouldAnimate
                    )
                
            }
            
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var shouldAnimate: Bool = false
    
    AppBaseView {
        
        DotsAnimationView(shouldAnimate: shouldAnimate)
            .frame(width: 32, height: 32)
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: CornerRadius.medium.value))
        
    }
    .onTapGesture {
        shouldAnimate.toggle()
    }
    
}
