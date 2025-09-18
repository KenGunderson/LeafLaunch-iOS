//
//  BusinessLocationStackView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/9/25.
//

import SwiftUI

struct LocationCardView: View {
    
    private let businessName: String
    private let businessLocation: Location
    private let role: Role
    
    let cornerRadius: CGFloat = Style.shared.radius(.small2)
    
    var backgroundColor: Color {
        switch role {
        case .owner: return GPColor.lightGreen
        case .manager: return GPColor.lightPurple
        default: return GPColor.lightOrange
        }
    }
    
    var tokenTextColor: Color {
        switch role {
        case .owner: return GPColor.green
        case .manager: return GPColor.purple
        default: return GPColor.orange
        }
    }
    
    var tokenBackgroundColor: Color {
        switch role {
        case .owner: return GPColor.fadedGreen
        case .manager: return GPColor.fadedPurple
        default: return GPColor.fadedOrange
        }
    }
    
    init(businessName: String,
         businessLocation: Location,
         role: Role) {
        
        self.businessName = businessName
        self.businessLocation = businessLocation
        self.role = role
        
    }
    
    var body: some View {
        
        VStack(spacing: Style.shared.spacing(.none)) {
            
            businessHeaderView()
            locationsListView()
            
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
        
        let tokenText: String = self.role.description
        
        return HStack {
            
            Text(self.businessName)
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TokenView(
                text: tokenText,
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
    
    private func locationsListView() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            locationLineItem(self.businessLocation)
            
        }
        .padding(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        
    }
    
    private func locationLineItem(_ location: Location) -> some View {
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                Text(location.name)
                    .appFont(with: .TITLE_3)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(location.address.fullFormattedAddress)
                    .appFont(with: .BODY_2)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
            
        }
        .foregroundStyle(Style.shared.textColor(.body).source())
        
    }
    
}

#Preview {
    
    let business: Business = MockModels.MockBusiness.business1
    let business2: Business = MockModels.MockBusiness.business2
    
    AppBaseView {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            LocationCardView(
                businessName: business.name,
                businessLocation: business.locations.first!,
                role: .owner
            )
            .padding(.horizontal, .medium)
            
            LocationCardView(
                businessName: business2.name,
                businessLocation: business2.locations.first!,
                role: .manager
            )
            .padding(.horizontal, .medium)
            
            LocationCardView(
                businessName: business2.name,
                businessLocation: business2.locations.first!,
                role: .employee
            )
            .padding(.horizontal, .medium)
            
        }
        
    }
    
}
