//
//  MediaLimitReachedAlert.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/22/25.
//

import SwiftUI

@MainActor
extension AppCardConfig {
    
    static func mediaLimitReachedAlert(businessName: String,
                                       isSubscribed: Bool,
                                       subscribeAction: @escaping () -> Void,
                                       closeAction: @escaping () -> Void) -> AppCardConfig {
        
        var isSubscribedText: String {
            
            if isSubscribed {
                return """
                You’re already on a GlowPro plan.

                To keep capturing new photos and videos this month, you can:\n
                • Upgrade your plan for a bigger monthly media limit.\n
                • Turn on “Allow Overages” in Security Settings
                """
            } else {
                return """
                You’ve filled up your free space for \(businessName).

                Start a GlowPro subscription to unlock more room for photos and videos and keep your client gallery looking fresh ✨
                """
            }
        }

        var actionTitle: String {
            isSubscribed ? "Upgrade" : "Subscribe"
        }

        let attributedText = AttributedText {
            
            Text("\(businessName) ")
                .font(Style.shared.font(.HEADER_1))
                .foregroundStyle(Style.shared.accent.source())
            
            Text("has reached its monthly media limit.")
                .foregroundStyle(Style.shared.textColor(.title).source())
                .font(Style.shared.font(.HEADER_1))
            
            Text("\n\n")
            
            Text("Good news: everything you’ve already saved is safe and sound. ")
                .font(Style.shared.font(.BODY_3))
                .foregroundStyle(Style.shared.textColor(.body).source())
            
            Text(isSubscribedText)
                .font(Style.shared.font(.BODY_3))
                .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        
        return .init(
            viewBuilder: { dismissAction in
                
                BaseAppCardConfigView(
                    image: .systemImage("camera.circle.fill"),
                    title: "Media Limit Reached",
                    attributedText: attributedText,
                    tintColor: Style.shared.accent,
                    actionTitle: actionTitle,
                    action: {
                        
                        dismissAction()
                        subscribeAction()
                        
                    })
                .overlay(alignment: .topTrailing) {
                    
                    CircularIconView(
                        foregroundColor: Style.shared.textColor(.titleInverted),
                        backgroundColor: .material(.ultraThinMaterial),
                        imageSource: .systemImage("xmark"),
                        size: 36
                    )
                    .asButton {
                        
                        dismissAction()
                        closeAction()
                        
                    }
                    .padding(.top, -Style.shared.spacing(.small2))
                    
                }
                .asAnyView()
                
            },
            cornerRadius: Style.shared.radius(.large),
            backgroundCardInset: .init(top: 0, left: 24, bottom: UIScreen.main.bounds.height * 0.20, right: 24),
            contentCardInset: .init(top: 40, left: 16, bottom: 40, right: 16),
            cardBackgroundColor: Style.shared.background(.secondary),
            shouldDismissOnOutsideTouch: false,
            shouldDismissOnDrag: false
        )
    }
    
}

#Preview {
    
    let alertService = mockResolve(AlertServiceProtocol.self)
    
    AppBaseView(alignment: .bottom) {
        
        CommonButton(title: "Show Alert") {
            
            alertService.showAlert(
                .init(.card(.mediaLimitReachedAlert(
                    businessName: "Bronx Tales",
                    isSubscribed: true,
                    subscribeAction: {
                        print("Subscribe Tapped")
                    }, closeAction: {
                        print("Done Tapped")
                    }))))
            
        }
        .padding(.horizontal, .extraLarge)
        
    }
    .withMockServices()
    
}
