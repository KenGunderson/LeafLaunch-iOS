//
//  BusinessEmployeeInviteView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/10/25.
//

import SwiftUI

struct BusinessEmployeeInviteView: View {
        
    private let email: String
    
    init(email: String) {
        self.email = email
    }
    
    var title: String {
        "Join an Existing Team"
    }

    var actionTitle: String {
        "View Pending Invites"
    }
    
    let accentColor: Color = GPColor.orange
    
    var body: some View {
        
        VStack(alignment: .leading,
               spacing: Style.shared.spacing(.small2)) {
            
            Text(self.title)
                .appFont(with: .TITLE_5)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            AttributedText {
                
                Text("You’ll be invited to join a business at ")
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .font(Style.shared.font(.BODY_2))
                
                Text(self.email.lowercased())
                    .foregroundStyle(self.accentColor)
                    .font(Style.shared.font(.TITLE_3))
                
                Text(". Once your employer sends the invite, you’ll be able to access the business and get started. Sit tight!")
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .font(Style.shared.font(.BODY_2))
                
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
            .foregroundStyle(self.accentColor)
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .medium2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GPColor.lightOrange.opacity(0.15))
        .clipShape(.rect(cornerRadius: Style.shared.radius(.small2)))
        .appBorder(cornerRadius: .small2, color: .color(self.accentColor), lineWidth: 2)
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        VStack {
            
            BusinessDashboardView(isBusinessActive: true)
            BusinessEmployeeInviteView(email: "Sako@me.com")
            
        }
        .padding(.horizontal, .large)
        
    }
    
}
