import SwiftUI

struct StoreAccountMembershipView: View {

    @Environment(\.style) private var style

    @State private var isPresentingDetails: Bool = false

    let account: CustomerAccount?
    let membership: CustomerLocationMembership?
    let locationName: String?
    let hasSelectedLocation: Bool
    let isLoading: Bool
    let hasCompletedInitialLoad: Bool
    let joinAction: () -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            if let account = self.account {

                StoreAccountMembershipCard(account: account) {
                    self.isPresentingDetails = true
                }

                Text(String(localized: "Member since \(account.createdAt.formatted(date: .abbreviated, time: .omitted))"))
                    .appFont(with: .BODY_1)
                    .foregroundStyle(self.style.textColor(.body))
                    .fixedSize(horizontal: false, vertical: true)

                enrollmentAction()

            } else {
                membershipPlaceholder()
            }

        }
        .sheet(isPresented: self.$isPresentingDetails) {

            if let account = self.account {

                StoreAccountMembershipDetailsView(
                    account: account,
                    membership: self.membership,
                    locationName: self.locationName
                )

            }

        }
        .onChange(of: self.account?.id) { _, _ in self.isPresentingDetails = false }

    }

    @ViewBuilder
    private func enrollmentAction() -> some View {

        if self.hasSelectedLocation && self.membership == nil && self.hasCompletedInitialLoad && !self.isLoading {

            LeafLaunchButton(title: String(localized: "Enable Location Activity"), action: self.joinAction)
                .padding(.top, .small)

        }

    }

    @ViewBuilder
    private func membershipPlaceholder() -> some View {

        CommerceSurface {

            if self.isLoading {

                ProgressView(String(localized: "Loading membership"))
                    .tint(self.style.palette(.link))

            } else {

                Text(String(localized: "Your membership details will appear here."))
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.body))

            }

        }

    }

}

#Preview("Member") {

    StoreAccountMembershipView(
        account: MockCustomerModels.account,
        membership: MockCustomerModels.membership,
        locationName: MockCustomerModels.locationDetails.location.name,
        hasSelectedLocation: true,
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
        locationName: nil,
        hasSelectedLocation: false,
        isLoading: false,
        hasCompletedInitialLoad: true,
        joinAction: {}
    )
    .padding(.medium)
    .withMockPreviews()

}
