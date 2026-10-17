import SwiftUI

struct StoreAccountMembershipView: View {

    @Environment(\.style) private var style

    let account: CustomerAccount?
    let membership: CustomerLocationMembership?
    let isLoading: Bool
    let hasCompletedInitialLoad: Bool
    let joinAction: () -> Void

    private var membershipStatus: String {

        switch self.account?.status {
        case .active: return String(localized: "Active member")
        case .suspended: return String(localized: "Membership suspended")
        case .banned: return String(localized: "Membership unavailable")
        case .anonymized: return String(localized: "Membership anonymized")
        case nil: return String(localized: "Membership")
        }

    }

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            CommerceSectionHeader(title: String(localized: "Your membership"))

            CommerceSurface {

                if let account {

                    membershipContent(account)

                    if self.membership == nil && self.hasCompletedInitialLoad && !self.isLoading {

                        LeafLaunchButton(title: String(localized: "Enable Location Activity"), action: self.joinAction)

                    }

                } else if self.isLoading {

                    ProgressView(String(localized: "Loading membership"))
                        .tint(self.style.foreground(.primary).source(style: self.style))

                } else {

                    Text(String(localized: "Your membership details will appear here."))
                        .appFont(with: .BODY_2)
                        .foregroundStyle(self.style.textColor(.body))

                }

            }

        }

    }

    @ViewBuilder
    private func membershipContent(_ account: CustomerAccount) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            membershipHeader()

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(account.cachedPointsBalance)
                    .appFont(with: .BILLBOARD_2)
                    .monospacedDigit()
                    .foregroundStyle(self.style.textColor(.title))

                Text(String(localized: "Points balance"))
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.body))

            }

            Divider().overlay(self.style.background(.border))

            membershipDetails(account)

        }

    }

    @ViewBuilder
    private func membershipHeader() -> some View {

        HStack(alignment: .top, spacing: self.style.spacing(.small)) {

            ImageSource.systemImage("seal").view(shouldResize: false)
                .appFont(with: .TITLE_5)
                .foregroundStyle(self.style.foreground(.primary))

            Text(self.membershipStatus)
                .appFont(with: .TITLE_3)
                .foregroundStyle(self.style.textColor(.title))

            Spacer(minLength: 0)

        }

    }

    @ViewBuilder
    private func membershipDetails(_ account: CustomerAccount) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            if !account.membershipCode.isEmpty {

                Text(String(localized: "Member ID · \(account.membershipCode)"))
                    .appFont(with: .TITLE_1)
                    .foregroundStyle(self.style.textColor(.title))
                    .textSelection(.enabled)

            }

            Text(String(localized: "Member since \(account.createdAt.formatted(date: .abbreviated, time: .omitted))"))
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))

        }

    }


}

#Preview("Member") {

    StoreAccountMembershipView(
        account: MockCustomerModels.account,
        membership: MockCustomerModels.membership,
        isLoading: false,
        hasCompletedInitialLoad: true,
        joinAction: {}
    )
    .padding(.medium)
    .withMockPreviews()

}

#Preview("Business membership without location") {

    StoreAccountMembershipView(
        account: MockCustomerModels.account,
        membership: nil,
        isLoading: false,
        hasCompletedInitialLoad: true,
        joinAction: {}
    )
    .padding(.medium)
    .withMockPreviews()

}
