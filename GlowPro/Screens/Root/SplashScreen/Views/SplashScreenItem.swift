//
//  SplashScreenItem.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 9/5/23.
//

import SwiftUI

struct SplashScreenItem: View {
    
    @Binding var isLoading: Bool
        
    var body: some View {
        
        AppBaseView(backgroundStyle: Style.shared.accent) {
            
            Text("GlowPro")
                .appFont(with: .BILLBOARD_3)
                .foregroundStyle(Style.shared.textColor(.titleInverted).source())
            
        }
        .onAppear {
            
            Task {
                
                try? await Task.sleep(for: Duration.seconds(1))
                
                withAnimation(.bouncy(duration: 1)) {
                    self.isLoading = false
                }
                
            }
            
        }
        
    }
    
}
