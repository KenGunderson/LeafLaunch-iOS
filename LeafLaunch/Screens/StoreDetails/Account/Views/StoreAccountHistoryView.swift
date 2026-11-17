import SwiftUI

struct StoreAccountHistoryView: View {

    @Environment(\.style) private var style

    let history: [LoyaltyHistoryEntry]
    let isLoading: Bool
    let hasCompletedInitialLoad: Bool
    let canViewAllHistory: Bool
    let viewAllAction: () -> Void

    var body: some View {

        LLSection(
            title: String(localized: "Points Activity"),
            actionTitle: String(localized: "View All"),
            action: self.canViewAllHistory ? self.viewAllAction : nil
        ) {
            historyContent()

        }

    }

    @ContentBuilder
    private func historyContent() -> some View {

        if self.hasCompletedInitialLoad && self.history.isEmpty {

            CommerceSurface {

                CommerceEmptyState(
                    systemImage: "clock.arrow.circlepath",
                    title: String(localized: "No Points Activity Yet"),
                    message: String(localized: "Your points and redemptions will appear here.")
                )

            }

        } else if self.history.isEmpty && self.isLoading {

            CommerceSurface {

                ProgressView(String(localized: "Loading Points Activity"))
                    .tint(RNColorSource.palette(.link))

            }

        } else if let entry = self.history.first {

            historyRow(entry)

        }

    }

    @ContentBuilder
    private func historyRow(_ entry: LoyaltyHistoryEntry) -> some View {

        CommerceSurface {
            StoreAccountHistoryRow(entry: entry)
        }

    }

}

#Preview {

    ScrollView {

        StoreAccountHistoryView(
            history: Array(MockCustomerModels.loyaltyHistory.prefix(5)),
            isLoading: false,
            hasCompletedInitialLoad: true,
            canViewAllHistory: true,
            viewAllAction: {}
        )
        .runePadding(LLSpacing.pageInset)

    }
    .withMockPreviews()

}
