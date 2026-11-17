import SwiftUI

struct StoreAccountProfileView: View {

    @Environment(\.style) private var style
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let user: LLUser
    let account: CustomerAccount?

    private var displayName: String {

        if let name = self.account?.displayName.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            return name
        }

        return self.user.fullName

    }

    private var accountStatus: String? {

        switch self.account?.status {
        case .active: return nil
        case .suspended: return String(localized: "Account Suspended")
        case .banned: return String(localized: "Account Restricted")
        case .anonymized: return String(localized: "Account Anonymized")
        case nil: return nil
        }

    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

            Text(String(localized: "Good To See You"))
                .runeFont(with: LeafLaunchThemeTokens.headingFont)
                .runeTextColor(.title)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            profileIdentity()

            if let accountStatus {

                Text(accountStatus)
                    .runeFont(with: .TITLE_1)
                    .runeTextColor(.title)

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .runePadding(.vertical, LLSpacing.groupedContent)

    }

    @ContentBuilder
    private func profileIdentity() -> some View {

        if self.dynamicTypeSize.isAccessibilitySize {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                avatar()
                identity()

            }

        } else {

            HStack(
                alignment: .center,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                avatar()
                identity()

            }

        }

    }

    @ContentBuilder
    private func avatar() -> some View {

        RNAvatarView(
            style: .initials(name: self.displayName),
            foregroundColor: RNColorSource.palette(.link),
            backgroundColor: .sourceWithOpacity(
                RNColorSource.palette(.link),
                opacity: 0.08,
                style: self.style
            )
        )
        .frame(
            width: self.style.spacing(.extraLarge),
            height: self.style.spacing(.extraLarge)
        )

    }

    @ContentBuilder
    private func identity() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.none)
        ) {

            Text(self.displayName)
                .runeFont(with: .TITLE_6)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .runeTextColor(.title)

            if !self.user.email.isEmpty {

                Text(self.user.email)
                    .runeFont(with: .BODY_1)
                    .runeTextColor(.body)
                    .textSelection(.enabled)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

}

#Preview {

    StoreAccountProfileView(
        user: MockCustomerModels.user,
        account: MockCustomerModels.account
    )
        .runePadding(LLSpacing.pageInset)
        .withMockPreviews()

}
