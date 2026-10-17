//
//  InvitationAlertView.swift
//  LeafLaunch
//

import SwiftUI

struct InvitationAlertView: View {

    @Environment(\.style) private var style

    let name: String
    let businessName: String
    let doneAction: () -> Void

    var body: some View {

        BaseAppCardConfigView(
            image: .systemImage("envelope.circle.fill"),
            title: "Invitation Sent!",
            attributedText: message(),
            actionTitle: "Done",
            action: self.doneAction
        )
        .accessibilityAction(.escape) {
            self.doneAction()
        }

    }

    private func message() -> AttributedText {

        AttributedText {

            Text(self.name)
                .foregroundStyle(.text(.title))
                .font(self.style.font(.HEADER_1))

            Text(" has been invited to join \(self.businessName). They will receive an email with next steps.")
                .font(self.style.font(.BODY_3))
                .foregroundStyle(.text(.body))

        }

    }

}

#Preview {

    InvitationAlertView(
        name: MockCustomerModels.user.fullName,
        businessName: MockCustomerModels.store.name,
        doneAction: {}
    )
    .padding(.medium)
    .withMockPreviews()

}
