//
//  EmployeeInviteView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/15/25.
//

import SwiftUI

struct EmployeeInviteView: View {
    
    private let employeeInvitation: EmployeeInvite
    private let deleteAction: () -> Void
    
    init(employeeInvitation: EmployeeInvite,
         deleteAction: @escaping () -> Void) {
            
        self.employeeInvitation = employeeInvitation
        self.deleteAction = deleteAction
            
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
                backgroundColor: .sourceWithOpacity(Style.shared.accent, opacity: 0.10)
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
        let locationsString = self.employeeInvitation.locationIds.count > 0 ? " at \(self.employeeInvitation.locationIds.count) location(s)" : ""
        
        HStack(spacing: Style.shared.spacing(.extraSmall)) {
            
            VStack {
                
                Text("\(self.employeeInvitation.name)\(finalRoleString)")
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(titleColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(self.employeeInvitation.email)\(locationsString)")
                    .appFont(with: .BODY_2)
                    .foregroundStyle(bodyColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(self.employeeInvitation.createdAt?.formatted(.relative(presentation: .numeric, unitsStyle: .narrow)) ?? "")
                .appFont(with: .BODY_1)
                .foregroundStyle(bodyColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    
                    RoundedRectangle(cornerRadius: Style.shared.radius(.extraSmall), style: .continuous)
                        .fill(Style.shared.background(.quinary).source())
                    
                )
            
            menu()
            
        }
        
    }
    
    private func menu() -> some View {
        
        Menu {
            
            Button(role: .destructive) {
                self.deleteAction()
            } label: {
                Label("Revoke Invitation", systemImage: "trash")
            }
            
        } label: {
            
            Image(systemName: "ellipsis")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .frame(width: 16, height: 16)
                .rotationEffect(.degrees(90))
                .padding(6)
            
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
                businessId: MockModels.ID.business1,
                businessName: "Yolo Bros",
                locationIds: [],
                role: .admin,
                createdAt: Date().addingTimeInterval(-1723712).toISO()
            )) {}
            
            EmployeeInviteView(employeeInvitation: .init(
                id: "1",
                name: "Power Man 3000",
                email: "sako@me.com",
                businessId: MockModels.ID.business1,
                businessName: "Yolo Bros",
                locationIds: [Location.DUMMY_DATA().id],
                role: .admin,
                createdAt: Date().toISO()
            )) {}
                               
            EmployeeInviteView(employeeInvitation: .DUMMY_DATA()) {}
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}
