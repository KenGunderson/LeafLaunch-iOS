//
//  InvitationAlert.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/18/25.
//

import SwiftUI

@MainActor
extension AppCardConfig {
    
    static func invitationAlert(name: String,
                                businessName: String,
                                doneAction: @escaping () -> Void) -> AppCardConfig {
        
        let attributedText = AttributedText {
            
            Text(name)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .font(Style.shared.font(.HEADER_1))
            
            Text(" has been invited to join \(businessName). They will receive an email with next steps.")
                .font(Style.shared.font(.BODY_3))
                .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        
        return .init(
            viewBuilder: { dismissAction in
                
                BaseAppCardConfigView(
                    image: .systemImage("envelope.circle.fill"),
                    title: "Invitation Sent!",
                    attributedText: attributedText,
                    actionTitle: "Done",
                    action: {
                        dismissAction()
                        doneAction()
                    })
                .asAnyView()
                
            },
            cornerRadius: Style.shared.radius(.large),
            backgroundCardInset: .init(top: 0, left: 24, bottom: 250, right: 24),
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
                .init(.card(.invitationAlert(
                    name: "Sako Hovaguimian",
                    businessName: "Bronx Tales"
                ) {
                    print("Testing")
                }
                )))
            
        }
        .padding(.horizontal, .extraLarge)
        
    }
    .withMockServices()
    
}
