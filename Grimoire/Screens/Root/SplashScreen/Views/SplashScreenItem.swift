//
//  SplashScreenItem.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 9/5/23.
//

import SwiftUI

struct SplashScreenItem: View {
    
    @Binding var isLoading: Bool
    
    @State private var size = 0.5
    
    var body: some View {
        
        AppBaseView {
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                Image(systemName: "person.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(.linearGradient(
                        colors: [
                            Style.shared.accent.asColor!,
                            Style.shared.accent.asColor!.opacity(0.5)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                
                Text("Grimoire")
                    .appFont(with: .BILLBOARD_B1)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
            }
            .scaleEffect(self.size)
            
        }
        .background(Style.shared.background(.primary).source())
        .onAppear {
            
            Task {
                
                try? await Task.sleep(for: Duration.seconds(0.3))
                
                withAnimation(.interpolatingSpring(
                    stiffness: 200,
                    damping: 5,
                    initialVelocity: 10)) {
                        
                    self.size = 1
                        
                }
                
                try? await Task.sleep(for: Duration.seconds(1.5))
                
                withAnimation(.bouncy(duration: 1.2)) {
                    
                    self.size = 10
                    self.isLoading = false
                    
                }
                
            }
            
        }
        
    }
    
}
