//
//  EmployeeInviteView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/15/25.
//

import SwiftUI

struct EmployeeInviteView: View {
    
    private let employeeInvitation: EmployeeInvite
    
    init(employeeInvitation: EmployeeInvite) {
        self.employeeInvitation = employeeInvitation
    }
    
    var body: some View {
        informationView()
    }
    
    private func informationView() -> some View {
        
        HStack(alignment: .center,
               spacing: Style.shared.spacing(.small)) {
            
            AvatarView(
                style: .initials(name: employeeInvitation.name),
                foregroundColor: Style.shared.accent,
                backgroundColor: .color(Style.shared.accent.asColor!.opacity(0.10))
            )
            .frame(
                width: 40,
                height: 40
            )
            .appBorder(
                cornerRadius: .custom(20),
                color: Style.shared.accent,
                lineWidth: 2
            )
            
            titleLine()
            
        }
               .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func titleLine() -> some View {
        
        let titleColor = Style.shared.textColor(.title).source()
        let bodyColor = Style.shared.textColor(.body).source()

        let roleString = "(\(self.employeeInvitation.role?.rawValue.capitalized ?? ""))"
        let finalRoleString = self.employeeInvitation.role == nil ? "" : " \(roleString)"
        let locationsString = self.employeeInvitation.locations.count > 0 ? " at \(self.employeeInvitation.locations.count) location(s)" : ""
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
            
            HStack {
                
                Text("\(self.employeeInvitation.name)\(finalRoleString)")
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(titleColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("2 hours ago")
                    .appFont(with: .BODY_1)
                    .foregroundStyle(bodyColor)
                
            }
            
            Text("\(self.employeeInvitation.email)\(locationsString)")
                .appFont(with: .BODY_2)
                .foregroundStyle(bodyColor)

        }
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            EmployeeInviteView(employeeInvitation: .init(
                id: "1",
                name: "Power Man 3000",
                email: "sako@me.com",
                businessName: "Yolo Bros",
                locations: [],
                role: .admin
            ))
            
            EmployeeInviteView(employeeInvitation: .init(
                id: "1",
                name: "Power Man 3000",
                email: "sako@me.com",
                businessName: "Yolo Bros",
                locations: [.DUMMY_DATA()],
                role: .admin
            ))
                               
            EmployeeInviteView(employeeInvitation: .DUMMY_DATA())
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}
