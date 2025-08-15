//
//  QuickActionTileView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/10/25.
//

import SwiftUI

struct QuickActionTileView: View {
    
    let icon: ImageSource
    let iconBackgroundColor: ColorSource
    let title: String
    let subtitle: String
    let prominentSubtitle: Bool
    
    init(icon: ImageSource,
         iconBackgroundColor: ColorSource,
         title: String,
         subtitle: String,
         prominentSubtitle: Bool = false) {
        
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.title = title
        self.subtitle = subtitle
        self.prominentSubtitle = prominentSubtitle
        
    }
    
    var body: some View {
        
        let subtitleFont: Theme.FontKey = self.prominentSubtitle ? .TITLE_6 : .BODY_1
        let subtitleColor = Style.shared.textColor(self.prominentSubtitle ? .title : .body)
        
        VStack(
            alignment: .leading,
            spacing: Style.shared.spacing(.none)
        ) {
            
            CircularIconView(
                foregroundColor: .color(.white),
                backgroundColor: self.iconBackgroundColor,
                imageSource: self.icon,
                size: 40
            )
            
            Text(self.title)
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .padding(.top, .small)
            
            HStack {
                
                Text(self.subtitle)
                    .appFont(with: subtitleFont)
                    .foregroundStyle(subtitleColor.source())
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
            }
            .padding(.top, .medium)
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Style.shared.background(.secondary).source())
        .cornerRadius(.small)
        
    }
    
}

#Preview {
    
    AppBaseView(backgroundStyle: .color(.gray.opacity(0.15))) {
        
        VStack {
            
            HStack {
                
                QuickActionTileView(
                    icon: .systemImage("person.fill"),
                    iconBackgroundColor: .color(.indigo),
                    title: "All Employees",
                    subtitle: "52",
                    prominentSubtitle: true
                )
                .asButton {}
                
                QuickActionTileView(
                    icon: .systemImage("house.fill"),
                    iconBackgroundColor: .color(.orange),
                    title: "Music",
                    subtitle: "32",
                    prominentSubtitle: true
                )
                .asButton {}
                
            }
            
            HStack {
                
                QuickActionTileView(
                    icon: .systemImage("person.fill"),
                    iconBackgroundColor: .color(.indigo),
                    title: "All Employees",
                    subtitle: "Hope this works",
                    prominentSubtitle: false
                )
                .asButton {}
                
                QuickActionTileView(
                    icon: .systemImage("house.fill"),
                    iconBackgroundColor: .color(.orange),
                    title: "Music",
                    subtitle: "Hope this works",
                    prominentSubtitle: false
                )
                .asButton {}
                
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}
