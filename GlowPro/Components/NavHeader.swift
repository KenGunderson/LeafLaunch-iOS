//
//  NavHeader.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/13/25.
//

import SwiftUI

struct NavHeader: View {
    
    private let title: String
    private let subtitle: String
    private let avatar: AvatarView.AvatarStyle?
    private let trailingNavButtons: [NavBarButton.Style]
    private let trailingNavButtonsAction: ((NavBarButton.Style) -> ())?
    
    init(title: String,
         subtitle: String,
         avatar: AvatarView.AvatarStyle? = nil,
         trailingNavButtons: [NavBarButton.Style] = [],
         trailingNavButtonsAction: ((NavBarButton.Style) -> ())? = nil) {
        
        self.title = title
        self.subtitle = subtitle
        self.avatar = avatar
        self.trailingNavButtons = trailingNavButtons
        self.trailingNavButtonsAction = trailingNavButtonsAction
        
    }
    
    var body: some View {
        
        HStack(spacing: Style.shared.spacing(.custom(10))) {
            
            avatarView()
            titleSubtitleView()
            trailingNavButtonsView()
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func avatarView() -> some View {
        
        if let avatar {
            
            AvatarView(
                style: avatar,
                backgroundColor: .color(Style.shared.accent.asColor!.opacity(0.25))
            )
            .frame(width: 40, height: 40)
            
        }
        
    }
    
    @ViewBuilder
    private func titleSubtitleView() -> some View {
        
        VStack(alignment: .leading) {
            
            Text(self.title)
                .appFont(with: .HEADER_2)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            Text(self.subtitle)
                .appFont(with: .BODY_1)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func trailingNavButtonsView() -> some View {
        
        HStack {
            
            ForEach(self.trailingNavButtons, id: \.self) { navStyle in
                
                NavBarButton(style: navStyle) {
                    self.trailingNavButtonsAction?(navStyle)
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    
    AppBaseView {
        
        VStack(spacing: 32) {
            
            NavHeader(
                title: "Good Morning, Sako",
                subtitle: "Select where you're working today",
                avatar: .initials(name: "Sako Hovaguimian"),
                trailingNavButtons: [
                    .bell(),
                    .settings
                ]
            ) { navItem in
                print(navItem)
            }
            
            NavHeader(
                title: "Good Morning, Sako",
                subtitle: "Select where you're working today"
            )
            
            NavHeader(
                title: "Good Morning, Sako",
                subtitle: "Select where you're working today",
                trailingNavButtons: [.plus]
            )
            
        }
        .padding(.horizontal, .large)
        
    }
    
}
