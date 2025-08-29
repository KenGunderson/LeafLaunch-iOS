//
//  OpenNewBusinessView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/29/25.
//

import SwiftUI

struct OpenNewBusinessView: View {
    
    private let title: String = "Create Your Business"
    private let message: String = "Set up your business profile to start managing locations, clients, media and growing with GlowPro."
    private let actionTitle: String = "Get Started"
    
    var body: some View {
        
        VStack(alignment: .leading,
               spacing: Style.shared.spacing(.small2)) {
            
            Text(self.title)
                .appFont(with: .TITLE_5)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            Text(self.message)
                .appFont(with: .BODY_2)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
            HStack(spacing: Style.shared.spacing(.extraSmall)) {
                
                Text(self.actionTitle)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                
            }
            .padding(.top, .extraSmall)
            .appFont(with: .TITLE_3)
            .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .medium2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            
            RoundedRectangle(cornerRadius: Style.shared.radius(.small2))
                .strokeBorder(style: .init(
                    lineWidth: 1.5,
                    dash: [5],
                    dashPhase: 1
                ), antialiased: true)
                .foregroundStyle(Style.shared.background(.quaternary).source())
            
        }
        .background(Style.shared.background(.quaternary).source(opacity: 0.35))
        .clipShape(.rect(cornerRadius: Style.shared.radius(.small2)))
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        OpenNewBusinessView()
            .padding(.horizontal, .large)
        
    }
    
}
