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
        .init(
            viewBuilder: { dismissAction in
                
                VStack(spacing: Style.shared.spacing(.large)) {
                    
                    Image(systemName: "envelope.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                        .foregroundStyle(GPColor.iconGreen)
                    
                    Text("Invitation Sent!")
                        .appFont(with: .HEADER_3)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                    AttributedText {
                        
                        Text(name)
                            .foregroundStyle(Style.shared.textColor(.title).source())
                            .font(Style.shared.font(.HEADER_1))
                     
                        Text(" has been invited to join \(businessName) They will receive an email with next steps.")
                            .font(Style.shared.font(.BODY_3))
                            .foregroundStyle(Style.shared.textColor(.body).source())
                        
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, -Style.shared.spacing(.small2))
                    .padding(.horizontal, .medium)
                    
                    CommonButton(title: "Done") {
                        dismissAction()
                        doneAction()
                    }
                    .padding(.horizontal, .medium)
                    
                }
                .frame(maxWidth: .infinity)
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
                    businessName: "Fattis Cockis"
                ) {
                    print("Testing")
                }
                )))
            
        }
        .padding(.horizontal, .extraLarge)
        
    }
    .withMockServices()
    
}
