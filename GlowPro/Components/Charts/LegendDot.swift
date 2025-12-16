//
//  LegendDot.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import SwiftUI

struct LegendDot: View {
    
    let title: String
    let color: Color
    
    var body: some View {
        
        HStack(spacing: Style.shared.spacing(.extraSmall)) {
            
            Circle()
                .fill(self.color)
                .frame(width: 12, height: 12)
            
            Text(self.title)
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
        }
        
    }
    
}
