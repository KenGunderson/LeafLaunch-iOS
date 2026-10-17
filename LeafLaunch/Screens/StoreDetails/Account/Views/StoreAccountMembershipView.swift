import SwiftUI

struct StoreAccountMembershipView: View {

    @Environment(\.style) private var style

    let membership: CustomerLocationMembership?
    let isLoading: Bool
    let hasCompletedInitialLoad: Bool
    let joinAction: () -> Void

    private var membershipStatus: String {

        switch self.membership?.status {
        case .active: return String(localized: "Active member")
        case .left: return String(localized: "Membership ended")
        case .anonymized: return String(localized: "Membership anonymized")
        case nil: return String(localized: "Membership")
        }

    }

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            CommerceSectionHeader(title: String(localized: "Your membership"))

            CommerceSurface {

                if let membership {

                    membershipContent(membership)

                } else if self.hasCompletedInitialLoad && !self.isLoading {

                    joinContent()

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
    private func membershipContent(_ membership: CustomerLocationMembership) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            membershipHeader()

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(membership.cachedPointsBalance)
                    .appFont(with: .BILLBOARD_2)
                    .monospacedDigit()
                    .foregroundStyle(self.style.textColor(.title))

                Text(String(localized: "Points balance"))
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.body))

            }

            Divider().overlay(self.style.background(.border))

            membershipDetails(membership)

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
    private func membershipDetails(_ membership: CustomerLocationMembership) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            if !membership.membershipCode.isEmpty {

                Text(String(localized: "Member ID · \(membership.membershipCode)"))
                    .appFont(with: .TITLE_1)
                    .foregroundStyle(self.style.textColor(.title))
                    .textSelection(.enabled)

            }

            Text(String(localized: "Member since \(membership.joinedAt.formatted(date: .abbreviated, time: .omitted))"))
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))

        }

    }

    @ViewBuilder
    private func joinContent() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            ImageSource.systemImage("seal").view(shouldResize: false)
                .appFont(with: .HEADER_3)
                .foregroundStyle(self.style.foreground(.primary))

            Text(String(localized: "Good things come with membership."))
                .appFont(with: .TITLE_5)
                .foregroundStyle(self.style.textColor(.title))

            Text(String(localized: "Join this location's loyalty program to earn points and see your activity here."))
                .appFont(with: .BODY_2)
                .foregroundStyle(self.style.textColor(.body))
                .fixedSize(horizontal: false, vertical: true)

            LeafLaunchButton(title: String(localized: "Join Loyalty Program"), action: self.joinAction)

        }

    }

}

#Preview("Member") {

    StoreAccountMembershipView(
        membership: MockCustomerModels.membership,
        isLoading: false,
        hasCompletedInitialLoad: true,
        joinAction: {}
    )
    .padding(.medium)
    .withMockPreviews()

}

#Preview("Join membership") {

    StoreAccountMembershipView(
        membership: nil,
        isLoading: false,
        hasCompletedInitialLoad: true,
        joinAction: {}
    )
    .padding(.medium)
    .withMockPreviews()

}
