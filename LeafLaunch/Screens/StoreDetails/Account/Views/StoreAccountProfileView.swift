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
        case .suspended: return String(localized: "Account suspended")
        case .banned: return String(localized: "Account restricted")
        case .anonymized: return String(localized: "Account anonymized")
        case nil: return nil
        }

    }

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            Text(String(localized: "Good To See You"))
                .appFont(with: .TITLE_5)
                .foregroundStyle(self.style.textColor(.title))
                .fixedSize(horizontal: false, vertical: true)

            profileIdentity()

            if let accountStatus {

                Text(accountStatus)
                    .appFont(with: .TITLE_1)
                    .foregroundStyle(self.style.textColor(.title))

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, self.style.spacing(.small))

    }

    @ViewBuilder
    private func profileIdentity() -> some View {

        if self.dynamicTypeSize.isAccessibilitySize {

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                avatar()
                identity()

            }

        } else {

            HStack(alignment: .center, spacing: self.style.spacing(.small2)) {

                avatar()
                identity()

            }

        }

    }

    @ViewBuilder
    private func avatar() -> some View {

        AvatarView(
            style: .initials(name: self.displayName),
            foregroundColor: self.style.palette(.link),
            backgroundColor: .sourceWithOpacity(self.style.palette(.link), opacity: 0.08, style: self.style)
        )
        .frame(width: self.style.spacing(.extraLarge), height: self.style.spacing(.extraLarge))

    }

    @ViewBuilder
    private func identity() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(self.displayName)
                .appFont(with: .TITLE_6)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(self.style.textColor(.title))

            if !self.user.email.isEmpty {

                Text(self.user.email)
                    .appFont(with: .BODY_1)
                    .foregroundStyle(self.style.textColor(.body))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

}

#Preview {

    StoreAccountProfileView(user: MockCustomerModels.user, account: MockCustomerModels.account)
        .padding(.medium)
        .withMockPreviews()

}
