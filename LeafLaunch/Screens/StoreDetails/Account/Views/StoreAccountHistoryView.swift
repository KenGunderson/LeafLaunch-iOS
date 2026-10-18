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

        HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small)) {

            Text(String(localized: "Points Activity"))
                .appFont(with: .TITLE_6)
                .foregroundStyle(self.style.textColor(.title))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            if self.canViewAllHistory {

                Text(String(localized: "View All"))
                    .appFont(with: .TITLE_1)
                    .foregroundStyle(self.style.palette(.link))
                    .fixedSize(horizontal: true, vertical: true)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                    .asButton(action: self.viewAllAction)

            }

        }

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
