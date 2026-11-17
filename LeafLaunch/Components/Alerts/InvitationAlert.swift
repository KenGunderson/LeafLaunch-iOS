//
//  InvitationAlert.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 8/18/25.
//

import SwiftUI

@MainActor
extension RNAlertCardConfig {

    static func invitationAlert(name: String,
                                businessName: String,
                                style: any RNStyleProtocol,
                                doneAction: @escaping () -> Void) -> RNAlertCardConfig {

        return .init(
            viewBuilder: { dismissAction in

                InvitationAlertView(
                    name: name,
                    businessName: businessName
                ) {

                    dismissAction()
                    doneAction()

                }
                .asAnyView()

            },
            cornerRadius: .theme(.large),
            backgroundCardInset: .init(
                top: style.spacing(LLSpacing.none),
                left: style.spacing(LLSpacing.content),
                bottom: style.spacing(LLSpacing.content),
                right: style.spacing(LLSpacing.content)
            ),
            contentCardInset: .init(
                top: style.spacing(.custom(40)),
                left: style.spacing(LLSpacing.pageInset),
                bottom: style.spacing(.custom(40)),
                right: style.spacing(LLSpacing.pageInset)
            ),
            cardBackgroundColor: .background(.secondary),
            shouldDismissOnOutsideTouch: false,
            shouldDismissOnDrag: false
        )

    }

}

#Preview {

    @Previewable @Environment(\.style) var style: any RNStyleProtocol

    let alertService = mockResolve(RNAlertServiceProtocol.self)

    RNBaseView(alignment: .bottom) {

        LeafLaunchButton(title: "Show Alert") {

            alertService.showAlert(
                .init(.card(.invitationAlert(
                    name: "Sako Hovaguimian",
                    businessName: "Bronx Tales",
                    style: style
                ) {
                    print("Testing")
                }
                )))

        }
        .runePadding(.horizontal, LLSpacing.hero)

    }
    .withMockServices()

}
