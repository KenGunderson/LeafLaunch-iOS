//
//  PendingInviteView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/9/25.
//

import SwiftUI

struct PendingInviteView: View {
    
    private let employeeInvitation: EmployeeInvite
    private let declineAction: () -> ()
    private let acceptAction: () -> ()
    
    init(employeeInvitation: EmployeeInvite,
         declineAction: @escaping () -> (),
         acceptAction: @escaping () -> ()) {
        
        self.employeeInvitation = employeeInvitation
        self.declineAction = declineAction
        self.acceptAction = acceptAction
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            informationView()
            actionsView()
            
        }
        
    }
    
    private func informationView() -> some View {
        
        HStack(alignment: .center,
               spacing: Style.shared.spacing(.small)) {
            
            AvatarView(
                style: .initials(name: employeeInvitation.name),
                foregroundColor: Style.shared.accent,
                backgroundColor: .color(Style.shared.accent.asColor!.opacity(0.25))
            )
            .frame(
                width: 40,
                height: 40
            )
            
            VStack(alignment: .leading,
                   spacing: Style.shared.spacing(.extraSmall)) {
                
                Text(self.employeeInvitation.businessName)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .font(Style.shared.font(.TITLE_2))
                + Text(" invited you to join")
                    .font(Style.shared.font(.BODY_1))
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
                Text("Please select an option below")
                    .appFont(with: .BODY_1)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .lineLimit(1)
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func actionsView() -> some View {
        
        HStack {
            
            CommonButton(
                style: .outline(lineWidth: 1.5),
                title: "Decline",
                titleColor: .color(.gray.opacity(0.8)),
                titleFont: .TITLE_2,
                backgroundStyle: .color(.gray.opacity(0.3)),
                verticalPadding: .small) {
                    declineAction()
                }
            
            CommonButton(
                title: "Accept",
                titleFont: .TITLE_2,
                verticalPadding: .small) {
                    acceptAction()
                }
            
        }
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            PendingInviteView(employeeInvitation: .DUMMY_DATA()) {
                // Dismiss Action
            } acceptAction: {
                // Accept Action
            }
            
            PendingInviteView(employeeInvitation: .DUMMY_DATA()) {
                // Dismiss Action
            } acceptAction: {
                // Accept Action
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}
