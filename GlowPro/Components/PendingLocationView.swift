//
//  PendingLocationView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/10/25.
//

import SwiftUI

struct PendingLocationView: View {
    
    private let simpleWorkspace: SimpleWorkspace
    
    let cornerRadius: CGFloat = Style.shared.radius(.small2)
    
    let backgroundColor: Color = GPColor.lightBlue
    let tokenTextColor: Color = GPColor.blue
    let tokenBackgroundColor: Color = GPColor.fadedBlue
    
    init(simpleWorkspace: SimpleWorkspace) {
        self.simpleWorkspace = simpleWorkspace
    }
    
    var body: some View {
        
        VStack(spacing: Style.shared.spacing(.none)) {
            
            businessHeaderView()
            messageView()
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(self.backgroundColor)
        .clipShape(.rect(cornerRadius: self.cornerRadius))
        .overlay {
            
            RoundedRectangle(cornerRadius: self.cornerRadius)
                .stroke(self.backgroundColor, lineWidth: 3.5)
            
        }
        
    }
    
    private func businessHeaderView() -> some View {
                
        return HStack {
            
            Text(self.simpleWorkspace.name)
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TokenView(
                text: "Pending",
                titleFont: .TITLE_1,
                foregroundStyle: .color(tokenTextColor),
                backgroundStyle: .color(tokenBackgroundColor)
            )
            .overlay {
                
                Capsule()
                    .stroke(tokenTextColor, lineWidth: 1)
                
            }
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(self.backgroundColor)
        
    }
    
    private func messageView() -> some View {
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                Text("You've Joined a New Workspace")
                    .appFont(with: .TITLE_3)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("You’ve successfully been added to this business as a workspace member, but a specific location hasn’t been assigned to you yet. Once your location access is set up, it will appear here automatically.")
                    .appFont(with: .BODY_2)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
        }
        .foregroundStyle(Style.shared.textColor(.body).source())
        .padding(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            PendingLocationView(
                simpleWorkspace: .init(id: "1", name: "Power Rangers HQ")
            )
            .padding(.horizontal, .medium)
            
        }
        
    }
    
}
