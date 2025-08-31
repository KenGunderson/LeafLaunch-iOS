//
//  ShutterButton.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//

import SwiftUI

public struct ShutterButton: View {
    
    let size: CGFloat
    let action: () -> Void
    let disabled: Bool
    
    public init(size: CGFloat = 78,
                disabled: Bool,
                action: @escaping () -> Void) {
        
        self.size = size
        self.disabled = disabled
        self.action = action
        
    }
    
    public var body: some View {
        
        Button(action: self.action) {
            
            ZStack {
                
                Circle()
                    .strokeBorder(.white.opacity(0.9), lineWidth: 4)
                    .frame(width: self.size, height: self.size)
                
                Circle()
                    .fill(.white)
                    .frame(width: self.size - 14, height: self.size - 14)
                
            }
            
        }
        .buttonStyle(.plain)
        .opacity(self.disabled ? 0.6 : 1)
        .scaleEffect(self.disabled ? 0.98 : 1)
        .disabled(self.disabled)
        
    }
    
}
