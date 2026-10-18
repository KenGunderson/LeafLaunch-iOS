import SwiftUI

struct StoreAccountHistoryView: View {

    @Environment(\.style) private var style

    let history: [LoyaltyHistoryEntry]
    let isLoading: Bool
    let hasCompletedInitialLoad: Bool
    let canViewAllHistory: Bool
    let viewAllAction: () -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            sectionHeader()
            historyContent()

        }

    }

    @ViewBuilder
    private func sectionHeader() -> some View {

        CommerceSectionHeader(
            title: String(localized: "Points Activity"),
            actionTitle: self.canViewAllHistory ? String(localized: "View All") : nil,
            action: self.canViewAllHistory ? self.viewAllAction : nil
        )

    }

    @ViewBuilder
    private func historyContent() -> some View {

        if self.hasCompletedInitialLoad && self.history.isEmpty && !self.isLoading {

            CommerceSurface {

                CommerceEmptyState(
                    systemImage: "clock.arrow.circlepath",
                    title: String(localized: "No Points Activity Yet"),
                    message: String(localized: "Your points and redemptions will appear here.")
                )

            }

        } else if self.history.isEmpty && self.isLoading {

            CommerceSurface {

                ProgressView(String(localized: "Loading points activity"))
                    .tint(self.style.palette(.link))

            }

        } else if let entry = self.history.first {

            historyRow(entry)

        }

    }

    @ViewBuilder
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
        .padding(.medium)

    }
    .withMockPreviews()

}
