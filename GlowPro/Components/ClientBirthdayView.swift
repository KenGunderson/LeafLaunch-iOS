//
//  ClientBirthdayView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/14/25.
//

import SwiftUI

struct ClientBirthdayView: View {
    
    let client: Client
    
    var formattedDate: String {
        
        guard let dob = client.dateOfBirth else { return "" }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.month, .day], from: dob)
        components.year = calendar.component(.year, from: Date())
        
        guard let normalizedDate = calendar.date(from: components) else { return "" }
        
        return normalizedDate.calendarDayRelativeString(
            nowOverride: "Today"
        )
        
    }
    
    var needsPrefix: Bool {
        
        return formattedDate != "Today" &&
               formattedDate != "Tomorrow" &&
               formattedDate != "Yesterday"
        
    }
    
    var body: some View {
        
        HStack {
            
            AvatarView(
                style: .initials(name: self.client.fullName),
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
            
            Text(self.client.fullName)
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(self.needsPrefix ? "in \(formattedDate)" : formattedDate)
                .appFont(with: .BODY_2)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        ClientBirthdayView(client: MockModels.MockClient.client1)
            .padding(.horizontal, .large)
        
    }
    
}
