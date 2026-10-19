import SwiftUI

struct StoreAccountGuestView: View {

    @Environment(\.style) private var style

    let createAccountAction: () -> Void
    let signInAction: () -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            welcome()

            CommerceSurface {

                VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

                    membershipPreview()
                    accountActions()

                }

            }

            Text(String(localized: """
                You're welcome to keep exploring as a guest. \
                Browse the shop and save your favorites anytime.
                """))
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))
                .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func welcome() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            AvatarView(
                style: .image(.systemImage("person.crop.circle")),
                foregroundColor: self.style.foreground(.primary),
                backgroundColor: self.style.background(.tertiary)
            )
            .frame(width: self.style.spacing(.extraLarge2), height: self.style.spacing(.extraLarge2))

            Text(String(localized: "Make Yourself At Home."))
                .appFont(with: .HEADER_3)
                .foregroundStyle(self.style.textColor(.title))

            Text(String(localized: "Your profile, membership, and points. All in one place."))
                .appFont(with: .BODY_2)
                .foregroundStyle(self.style.textColor(.body))
                .fixedSize(horizontal: false, vertical: true)

        }
        .padding(.top, self.style.spacing(.small))

    }

    @ViewBuilder
    private func membershipPreview() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            ImageSource.systemImage("sparkles").view(shouldResize: false)
                .appFont(with: .TITLE_5)
                .foregroundStyle(self.style.foreground(.primary))

            Text(String(localized: "A Little More Rewarding"))
                .appFont(with: .TITLE_5)
                .foregroundStyle(self.style.textColor(.title))

            Text(String(localized: """
                Create an account to join this location's loyalty program \
                and follow your points activity.
                """))
                .appFont(with: .BODY_2)
                .foregroundStyle(self.style.textColor(.body))
                .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func accountActions() -> some View {

        VStack(spacing: self.style.spacing(.small2)) {

            LeafLaunchButton(title: String(localized: "Create Account"), action: self.createAccountAction)

            CommonButton(
                style: .outline(lineWidth: 1),
                title: String(localized: "Sign In"),
                titleColor: self.style.textColor(.title),
                titleFont: .TITLE_3,
                backgroundStyle: self.style.background(.border),
                verticalPadding: .small2,
                cornerRadius: .medium,
                action: self.signInAction
            )

        }

    }

}

#Preview {

    ScrollView {

        StoreAccountGuestView(createAccountAction: {}, signInAction: {})
            .padding(.medium)

    }
    .withMockPreviews()

}
