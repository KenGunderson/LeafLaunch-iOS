//
//  NoContentView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/17/25.
//

import SwiftUI

struct EmptyStateView: View {
    
    let config: EmptyStateConfig
    
    var body: some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            self.config
                .image
                .view()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .frame(width: 100, height: 120)
            
            Text(self.config.title)
                .appFont(with: .HEADER_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .multilineTextAlignment(.center)
            
            if let message = self.config.message {
                
                Text(message)
                    .appFont(with: .BODY_3)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .multilineTextAlignment(.center)
                
            }
            
            if let actionTitle = self.config.actionTitle {
                
                CommonButton(title: actionTitle) {
                    self.config.action?()
                }
                .padding(.top, .medium2)
                
            }
            
        }
        .padding(.horizontal, .large)
        
    }
    
}

#Preview {
    
    EmptyStateView(config: .init(
        title: "No Clients Found",
        message: "Start building your client base by adding your first client",
        image: .systemImage("magnifyingglass"),
        actionTitle: "Add Your First Client",
        action: {
            print("Do Something")
        }
    ))
    
}
