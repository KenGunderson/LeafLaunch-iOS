//
//  LegendItem.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import SwiftUI

struct LegendItem: View {
    
    let title: String
    let color: ColorSource
    let image: ImageSource
    
    var body: some View {
        
        HStack(spacing: Style.shared.spacing(.custom(6))) {
            
            self.image
                .view()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundStyle(self.color.source())
            
            Text(self.title)
                .font(.appFont(.TITLE_2))
                .foregroundStyle(Style.shared.textColor(.title).source())
            
        }
        
    }
    
}
