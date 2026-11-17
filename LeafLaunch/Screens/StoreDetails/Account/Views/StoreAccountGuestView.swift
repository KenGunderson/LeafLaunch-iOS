import SwiftUI

struct StoreAccountGuestView: View {

    @Environment(\.style) private var style

    let createAccountAction: () -> Void
    let signInAction: () -> Void

    var body: some View {

        LLAppCardView(
            backgroundStyle: .sourceWithOpacity(
                RNColorSource.palette(.link),
                opacity: 0.05,
                style: self.style
            ),
            cornerRadius: .extraLarge,
            borderColor: .sourceWithOpacity(
                RNColorSource.palette(.link),
                opacity: 0.18,
                style: self.style
            )
        ) {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.content)
            ) {

                welcome()

                CommerceSurface {

                    VStack(
                        alignment: .leading,
                        spacing: self.style.spacing(LLSpacing.content)
                    ) {

                        membershipPreview()
                        accountActions()

                    }

                }

                guestNote()

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    @ContentBuilder
    private func welcome() -> some View {

        HStack(
            alignment: .top,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

            brandMark()
            welcomeCopy()

        }

    }

    @ContentBuilder
    private func brandMark() -> some View {

        RNImageSource.image(ImageResource(
            name: BusinessConfig.logoAssetName,
            bundle: .main
        ))
            .view()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: self.style.spacing(.extraLarge),
                height: self.style.spacing(.extraLarge)
            )
            .runeCornerRadius(.medium2)
            .runeBorder(
                cornerRadius: .medium2,
                color: .sourceWithOpacity(
                    RNColorSource.palette(.link),
                    opacity: 0.2,
                    style: self.style
                ),
                lineWidth: 0.8
            )
            .accessibilityHidden(true)

    }

    @ContentBuilder
    private func welcomeCopy() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            Text(String(localized: "Make Yourself At Home"))
                .runeFont(with: LeafLaunchThemeTokens.headingFont)
                .runeTextColor(.title)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(String(localized: "Your profile, membership, and points. All in one place."))
                .runeFont(with: .BODY_1)
                .runeTextColor(.body)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func guestNote() -> some View {

        Text(String(localized: "You can keep browsing and save favorites as a guest."))
            .runeFont(with: .BODY_1)
            .runeTextColor(.body)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

    }

    @ContentBuilder
    private func membershipPreview() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            RNImageSource.systemImage("sparkles").view(shouldResize: false)
                .runeFont(with: .TITLE_5)
                .runeForeground(.primary)

            Text(String(localized: "A Little More Rewarding"))
                .runeFont(with: LeafLaunchThemeTokens.headingFont)
                .runeTextColor(.title)

            Text(String(localized: """
                Create an account to join this location's loyalty program \
                and follow your points activity.
                """))
                .runeFont(with: .BODY_2)
                .runeTextColor(.body)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

        }

    }

    @ContentBuilder
    private func accountActions() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            LeafLaunchButton(
                title: String(localized: "Create Account"),
                cornerRadius: .medium2,
                action: self.createAccountAction
            )

            LeafLaunchButton(
                style: .outline(lineWidth: 1),
                title: String(localized: "Sign In"),
                titleColor: RNColorSource.text(.title),
                titleFont: .TITLE_3,
                backgroundStyle: RNColorSource.background(.border),
                verticalPadding: .small2,
                cornerRadius: .medium2,
                action: self.signInAction
            )

        }

    }

}

#Preview {

    ScrollView {

        StoreAccountGuestView(
            createAccountAction: {},
            signInAction: {}
        )
            .runePadding(LLSpacing.pageInset)

    }
    .withMockPreviews()

}
