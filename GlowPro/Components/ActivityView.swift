//
//  ActivityView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/26/25.
//

import SwiftUI

struct ActivityView: View {
    
    let activity: Activity

    var body: some View {
        
        HStack {
            
            icon()
            title()
            date()
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    private func icon() -> some View {
        
        self.activity.activityType.icon
            .view(
                shouldResize: false,
                renderingMode: .template
            )
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(self.activity.activityType.tintColor)
            .frame(width: 36, height: 36)
            .background(self.activity.activityType.tintColor.opacity(0.15))
            .clipShape(.circle)
            .appBorder(
                cornerRadius: .custom(64),
                color: .color(self.activity.activityType.tintColor),
                lineWidth: 2
            )
        
    }
    
    private func title() -> some View {
        
        Text(self.activity.activityType.displayName)
            .appFont(with: .TITLE_4)
            .foregroundStyle(Style.shared.textColor(.title).source())
            .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func date() -> some View {
        
        return Text(self.activity.createdAt?.relativeDateString() ?? "")
            .appFont(with: .BODY_2)
            .foregroundStyle(Style.shared.textColor(.body).source())
        
    }
    
}

#Preview {
    
    VStack(spacing: 6) {
     
        ForEach(MockModels.allActivities, id: \.id) { activity in
            
            ActivityView(activity: activity)
            
        }
        
    }
    .padding(.horizontal, .large)
    
}
