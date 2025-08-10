//
//  BusinessLocationStackView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/9/25.
//

import SwiftUI

struct BusinessLocationStackView: View {
    
    private let business: Business
    private let isOwner: Bool
    private let selectedLocationAction: (Location) -> ()
    
    let cornerRadius: CGFloat = Style.shared.radius(.small2)
    
    var backgroundColor: Color {
        return self.isOwner ? GPColor.lightOrange : GPColor.lightPurple
    }
    
    init(business: Business,
         isOwner: Bool,
         selectedLocationAction: @escaping (Location) -> ()) {
        
        self.business = business
        self.isOwner = isOwner
        self.selectedLocationAction = selectedLocationAction
        
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
                .stroke(self.backgroundColor, lineWidth: 1)
            
        }
        
    }
    
    private func businessHeaderView() -> some View {
        
        let tokenText = self.isOwner ? "Owner" : "Employee"
        let tokenTextColor = self.isOwner ? GPColor.orange : GPColor.purple
        let tokenBackgroundColor = self.isOwner ? GPColor.fadedOrange : GPColor.fadedPurple
        
        return HStack {
            
            Text(self.business.name)
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
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
        .padding(.leading, .medium)
        .padding(.vertical, .small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(self.backgroundColor)
        
    }
    
    private func locationsListView() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            ForEach(self.business.locations, id: \.id) { location in
                locationLineItem(location)
            }
            
        }
        .padding(.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        
    }
    
    private func locationLineItem(_ location: Location) -> some View {
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            
            Text(location.formattedAddress)
                .appFont(with: .BODY_2)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
            
        }
        .foregroundStyle(Style.shared.textColor(.body).source())
        .asButton(scale: 0.99) {
            self.selectedLocationAction(location)
        }
        
    }
    
}

#Preview {
    
    var business: Business = MockModels.MockBusiness.business1
    var business2: Business = MockModels.MockBusiness.business2
    
    AppBaseView {
        
        VStack(spacing: Style.shared.spacing(.extraLarge)) {
            
            BusinessLocationStackView(
                business: business,
                isOwner: true
            ) { location in
                
                print(location)
                
            }
            .padding(.horizontal, .large)
            
            BusinessLocationStackView(
                business: business2,
                isOwner: false
            ) { location in
                
                print(location)
                
            }
            .padding(.horizontal, .large)
            
        }
        
    }
    
}
