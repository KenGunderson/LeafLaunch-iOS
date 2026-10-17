//
//  InvitationAlert.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 8/18/25.
//

import SwiftUI

@MainActor
extension AppCardConfig {

    static func invitationAlert(name: String,
                                businessName: String,
                                doneAction: @escaping () -> Void) -> AppCardConfig {

        return .init(
            viewBuilder: { dismissAction in

                InvitationAlertView(name: name, businessName: businessName) {

                    dismissAction()
                    doneAction()

                }
                .asAnyView()

            },
            cornerRadius: Style.shared.radius(.large),
            backgroundCardInset: .init(top: 0, left: 24, bottom: Style.shared.spacing(.large), right: 24),
            contentCardInset: .init(top: 40, left: 16, bottom: 40, right: 16),
            cardBackgroundColor: .background(.secondary),
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
        .padding(.horizontal, .large2)

    }
    .withMockServices()

}
