//
//  IconTitleSubtitle.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/12/25.
//

import SwiftUI

struct LineItemView: View {
    
    var title: String
    var value: String
    var systemName: String
    
    var body: some View {
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            Image(systemName: self.systemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundStyle(Style.shared.accent.source())
            
            Text(self.title)
                .appFont(with: .BODY_2)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
            Text(self.value)
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .padding(.leading, -2)
            
        }
        
    }
    
}
