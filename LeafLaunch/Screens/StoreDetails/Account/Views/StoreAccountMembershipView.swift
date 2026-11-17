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

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            if let account = self.account {

                StoreAccountMembershipCard(account: account) {
                    self.isPresentingDetails = true
                }

                Text(String(localized: "Member Since \(account.createdAt.formatted(date: .abbreviated, time: .omitted))"))
                    .runeFont(with: .BODY_1)
                    .runeTextColor(.body)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

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

    @ContentBuilder
    private func enrollmentAction() -> some View {

        let needsEnrollment = self.hasSelectedLocation && self.membership == nil
        let canEnroll = self.hasCompletedInitialLoad && !self.isLoading

        if needsEnrollment && canEnroll {

            LeafLaunchButton(
                title: String(localized: "Enable Location Activity"),
                action: self.joinAction
            )
                .runePadding(.top, LLSpacing.groupedContent)

        }

    }

    @ContentBuilder
    private func membershipPlaceholder() -> some View {

        CommerceSurface {

            if self.isLoading {

                ProgressView(String(localized: "Loading Membership"))
                    .tint(RNColorSource.palette(.link))

            } else {

                Text(String(localized: "Your membership details will appear here."))
                    .runeFont(with: .BODY_2)
                    .runeTextColor(.body)

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
    .runePadding(LLSpacing.pageInset)
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
    .runePadding(LLSpacing.pageInset)
    .withMockPreviews()

}
