//
//  NavHeader.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/13/25.
//

import SwiftUI

struct NavHeader: View {
    
    private let title: String
    private let subtitle: String?
    private let showLogo: Bool
    private let backgroundStyle: ColorSource
    private let leadingNavButtons: [NavBarButton.Style]
    private let leadingNavButtonsAction: ((NavBarButton.Style) -> ())?
    private let trailingNavButtons: [NavBarButton.Style]
    private let trailingNavButtonsAction: ((NavBarButton.Style) -> ())?
    
    init(title: String,
         subtitle: String? = nil,
         showLogo: Bool = false,
         backgroundStyle: ColorSource = Style.shared.background(.primary),
         leadingNavButtons: [NavBarButton.Style] = [],
         leadingNavButtonsAction: ((NavBarButton.Style) -> ())? = nil,
         trailingNavButtons: [NavBarButton.Style] = [],
         trailingNavButtonsAction: ((NavBarButton.Style) -> ())? = nil) {
        
        self.title = title
        self.subtitle = subtitle
        self.showLogo = showLogo
        self.backgroundStyle = backgroundStyle
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
            
            if self.showLogo {
                
                Image(.illustrationLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            } else {
                
                titleSubtitleView()
                
            }
            
            if !self.trailingNavButtons.isEmpty {
                
                navButtons(
                    self.trailingNavButtons,
                    action: self.trailingNavButtonsAction
                )
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .medium)
        .background(self.backgroundStyle.source())
        .background {
            
            Rectangle()
                .fill(self.backgroundStyle.source())
                .blur(radius: 2)
                .offset(y: 10)
            
        }
        
    }
    
    @ViewBuilder
    private func titleSubtitleView() -> some View {
        
        VStack(alignment: .leading) {
            
            Text(self.title)
                .appFont(with: .HEADER_2)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            if let subtitle = self.subtitle {
                
                Text(subtitle)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .minimumScaleFactor(0.5)
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func navButtons(_ buttons: [NavBarButton.Style],
                            action: ((NavBarButton.Style) -> ())? = nil) -> some View {
        
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
                showLogo: true,
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

#Preview {
    
    AppHeaderScrollView(navBarContent: {
        
        NavHeader(
            title: "Good Morning, Sako",
            subtitle: "Select where you're working today",
            showLogo: true,
            trailingNavButtons: [
                .bell(notificationCount: 1),
                .settings
            ]
        ) { navItem in
            print(navItem)
        }
        
    }, scrollViewContent: {
     
        VStack(spacing: 24) {
            
            RoundedRectangle(cornerRadius: 16)
                .fill(.red)
                .frame(height: 120)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(.red)
                .frame(height: 120)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(.red)
                .frame(height: 120)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(.red)
                .frame(height: 120)
            
        }
        
    })
    
}
