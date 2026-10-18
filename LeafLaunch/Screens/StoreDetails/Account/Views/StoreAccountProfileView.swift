import SwiftUI

struct StoreAccountProfileView: View {

    @Environment(\.style) private var style

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

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            ViewThatFits(in: .horizontal) {

                HStack(alignment: .center, spacing: self.style.spacing(.medium)) {

                    avatar()
                    identity()

                }

                VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                    avatar()
                    identity()

                }

            }

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
    private func avatar() -> some View {

        AvatarView(
            style: .initials(name: self.displayName),
            foregroundColor: self.style.palette(.link),
            backgroundColor: .color(self.style.palette(.link).resolvedColor(style: self.style)?.opacity(0.08) ?? .clear)
        )
        .frame(width: self.style.spacing(.extraLarge2), height: self.style.spacing(.extraLarge2))

    }

    @ViewBuilder
    private func identity() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(String(localized: "Good to see you"))
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))

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

    }

}

#Preview {

    StoreAccountProfileView(user: MockCustomerModels.user, account: MockCustomerModels.account)
        .padding(.medium)
        .withMockPreviews()

}
