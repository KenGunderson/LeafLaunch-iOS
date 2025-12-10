//
//  ActiveWorkspaceView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/9/25.
//

import SwiftUI

struct ActiveWorkspaceView: View {
        
    private let workspace: Workspace
    
    init(workspace: Workspace) {
        self.workspace = workspace
    }
    
    var title: String {
        return workspace.name
    }
    
    var message: String {
        return "Manage your business from your dashboard"
    }
    
    var actionTitle: String {
        return "Go To Dashboard"
    }
    
    var body: some View {
        
        let icon = ActivityCategory.business.icon
        let color: Color = ActivityCategory.business.color
        
        VStack(alignment: .leading,
               spacing: Style.shared.spacing(.small2)) {
            
            CircularIconView(
                foregroundColor: .color(color),
                backgroundColor: .color(color.opacity(0.10)),
                imageSource: icon,
                size: 40
            )
            .appBorder(
                cornerRadius: .custom(24),
                color: .color(color),
                lineWidth: 2
            )
            
            VStack(alignment: .leading,
                   spacing: 2) {
                
                Text(self.title)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Text(self.message)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
            }
            
            HStack(spacing: Style.shared.spacing(.extraSmall)) {
                
                Text(self.actionTitle)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                
            }
            .padding(.top, .extraSmall)
            .appFont(with: .TITLE_3)
            .foregroundStyle(color)
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .medium2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: Style.shared.radius(.small2)))
        .appBorder(cornerRadius: .small2, color: .color(color), lineWidth: 2)
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        ActiveWorkspaceView(workspace: MockModels.allWorkspaces.first!)
            .padding(.horizontal, .large)
        
    }
    
}
