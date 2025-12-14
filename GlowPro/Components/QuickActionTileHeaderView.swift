//
//  QuickActionTileHeaderView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/2/25.
//

import SwiftUI

struct QuickActionTileHeaderView: View {
    
    let icon: ImageSource
    let iconBackgroundColor: ColorSource
    let title: String
    let subtitle: String
    let backgroundStyle: ColorSource
    
    init(icon: ImageSource,
         iconBackgroundColor: ColorSource,
         title: String,
         subtitle: String,
         backgroundStyle: ColorSource = Style.shared.background(.secondary)) {
        
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.title = title
        self.subtitle = subtitle
        self.backgroundStyle = backgroundStyle
        
    }
    
    var body: some View {
        
        let subtitleFont: Theme.FontKey = .BODY_1
        let subtitleColor = Style.shared.textColor(.body)
        
        HStack(spacing: Style.shared.spacing(.small2)) {
            
            CircularIconView(
                foregroundColor: self.iconBackgroundColor,
                backgroundColor: .color(self.iconBackgroundColor.asColor!.opacity(0.10)),
                imageSource: self.icon,
                size: 40
            )
            .appBorder(
                cornerRadius: .custom(24),
                color: self.iconBackgroundColor,
                lineWidth: 2
            )
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                
                Text(self.title)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(self.subtitle)
                    .appFont(with: subtitleFont)
                    .foregroundStyle(subtitleColor.source())
                    .contentTransition(.numericText())
                
            }
            
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(self.backgroundStyle.source())
        .cornerRadius(.small)
        
    }
    
}

#Preview {
    
    AppBaseView(backgroundStyle: .color(.gray.opacity(0.15))) {
        
        QuickActionTileHeaderView(
            icon: .systemImage("person.fill"),
            iconBackgroundColor: .color(.indigo),
            title: "All Employees",
            subtitle: "52"
        )
        .asButton {}
        .padding(.horizontal, .medium)
        
    }
    
}
