import SwiftUI

struct StoreAccountGuestView: View {

    @Environment(\.style) private var style

    let createAccountAction: () -> Void
    let signInAction: () -> Void

    var body: some View {

        LLAppCardView(
            backgroundStyle: .sourceWithOpacity(self.style.palette(.link), opacity: 0.05, style: self.style),
            cornerRadius: .extraLarge,
            borderColor: .sourceWithOpacity(self.style.palette(.link), opacity: 0.18, style: self.style)
        ) {

            VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

                welcome()

                CommerceSurface {

                    VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

                        membershipPreview()
                        accountActions()

                    }

                }

                guestNote()

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    @ViewBuilder
    private func welcome() -> some View {

        HStack(alignment: .top, spacing: self.style.spacing(.small2)) {

            brandMark()
            welcomeCopy()

        }

    }

    @ViewBuilder
    private func brandMark() -> some View {

        ImageSource.image(ImageResource(name: BusinessConfig.logoAssetName, bundle: .main))
            .view()
            .aspectRatio(contentMode: .fit)
            .frame(width: self.style.spacing(.extraLarge), height: self.style.spacing(.extraLarge))
            .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
            .appBorder(
                cornerRadius: .medium2,
                color: .sourceWithOpacity(self.style.palette(.link), opacity: 0.2, style: self.style),
                lineWidth: 0.8
            )
            .accessibilityHidden(true)

    }

    @ViewBuilder
    private func welcomeCopy() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            Text(String(localized: "Make Yourself At Home"))
                .appFont(with: LeafLaunchThemeTokens.headingFont)
                .foregroundStyle(self.style.textColor(.title))
                .fixedSize(horizontal: false, vertical: true)

            Text(String(localized: "Your profile, membership, and points. All in one place."))
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))
                .fixedSize(horizontal: false, vertical: true)

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func guestNote() -> some View {

        Text(String(localized: "You can keep browsing and save favorites as a guest."))
            .appFont(with: .BODY_1)
            .foregroundStyle(self.style.textColor(.body))
            .fixedSize(horizontal: false, vertical: true)

    }

    @ViewBuilder
    private func membershipPreview() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            ImageSource.systemImage("sparkles").view(shouldResize: false)
                .appFont(with: .TITLE_5)
                .foregroundStyle(self.style.foreground(.primary))

            Text(String(localized: "A Little More Rewarding"))
                .appFont(with: LeafLaunchThemeTokens.headingFont)
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

            LeafLaunchButton(
                title: String(localized: "Create Account"),
                cornerRadius: .medium2,
                action: self.createAccountAction
            )

            CommonButton(
                style: .outline(lineWidth: 1),
                title: String(localized: "Sign In"),
                titleColor: self.style.textColor(.title),
                titleFont: .TITLE_3,
                backgroundStyle: self.style.background(.border),
                verticalPadding: .small2,
                cornerRadius: .medium2,
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
