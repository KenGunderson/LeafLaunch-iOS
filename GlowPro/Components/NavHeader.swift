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
    private let leadingNavButtons: [NavBarButton.Style]
    private let leadingNavButtonsAction: ((NavBarButton.Style) -> ())?
    private let trailingNavButtons: [NavBarButton.Style]
    private let trailingNavButtonsAction: ((NavBarButton.Style) -> ())?
    
    init(title: String,
         subtitle: String,
         avatar: AvatarView.AvatarStyle? = nil,
         leadingNavButtons: [NavBarButton.Style] = [],
         leadingNavButtonsAction: ((NavBarButton.Style) -> ())? = nil,
         trailingNavButtons: [NavBarButton.Style] = [],
         trailingNavButtonsAction: ((NavBarButton.Style) -> ())? = nil) {
        
        self.title = title
        self.subtitle = subtitle
        self.avatar = avatar
        self.leadingNavButtons = leadingNavButtons
        self.leadingNavButtonsAction = leadingNavButtonsAction
        self.trailingNavButtons = trailingNavButtons
        self.trailingNavButtonsAction = trailingNavButtonsAction
        
    }
    
    var body: some View {
        
        HStack(spacing: Style.shared.spacing(.custom(10))) {
            
            if !self.leadingNavButtons.isEmpty {
                
                navButtons(
                    self.leadingNavButtons,
                    action: self.leadingNavButtonsAction
                )
                
            }
            
            if let avatar {
                avatarView(avatar)
            }
            
            titleSubtitleView()
            
            if !self.trailingNavButtons.isEmpty {
                
                navButtons(
                    self.trailingNavButtons,
                    action: self.trailingNavButtonsAction
                )
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func avatarView(_ avatar: AvatarView.AvatarStyle) -> some View {
        
        AvatarView(
            style: avatar,
            backgroundColor: .color(Style.shared.accent.asColor!.opacity(0.25))
        )
        .frame(width: 40, height: 40)
        
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
    private func navButtons(_ buttons: [NavBarButton.Style], action: ((NavBarButton.Style) -> ())? = nil) -> some View {
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            ForEach(buttons, id: \.self) { navStyle in
                
                NavBarButton(style: navStyle) {
                    action?(navStyle)
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
                    .bell(notificationCount: 1),
                    .settings
                ]
            ) { navItem in
                print(navItem)
            }
            
            NavHeader(
                title: "Good Morning, Sako",
                subtitle: "Select where you're working today",
                leadingNavButtons: [.back],
                leadingNavButtonsAction: { _ in }
            )
            
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
        .padding(.horizontal, .medium)
        
    }
    
}
