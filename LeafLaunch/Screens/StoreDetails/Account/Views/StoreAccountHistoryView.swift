import SwiftUI

struct StoreAccountHistoryView: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let history: [LoyaltyHistoryEntry]
    let isLoading: Bool
    let hasCompletedInitialLoad: Bool
    let hasMoreHistory: Bool
    let loadMoreAction: () -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            CommerceSectionHeader(
                title: String(localized: "Points activity"),
                subtitle: String(localized: "Your points and redemption history")
            )

            CommerceSurface {

                VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                    historyContent()

                    if self.hasMoreHistory {

                        CommonButton(
                            style: .outline(lineWidth: 1),
                            title: String(localized: "Load More History"),
                            titleColor: self.style.textColor(.title),
                            titleFont: .TITLE_3,
                            backgroundStyle: self.style.background(.border),
                            isEnabled: !self.isLoading,
                            verticalPadding: .small2,
                            cornerRadius: .medium,
                            buttonBounceStyle: self.reduceMotion
                                ? .init(scale: 1, opacity: 1, brightness: 0)
                                : self.style.buttonBounceStyle,
                            action: self.loadMoreAction
                        )

                    }

                }

            }

        }

    }

    @ViewBuilder
    private func historyContent() -> some View {

        if self.hasCompletedInitialLoad && self.history.isEmpty {

            CommerceEmptyState(
                systemImage: "clock.arrow.circlepath",
                title: String(localized: "No points activity yet"),
                message: String(localized: "No points activity yet. Your points and redemptions will appear here.")
            )

        } else if self.history.isEmpty && self.isLoading {

            ProgressView(String(localized: "Loading points activity"))
                .tint(self.style.foreground(.primary).source(style: self.style))

        } else {

            ForEach(self.history, id: \.id) { entry in

                StoreAccountHistoryRow(entry: entry)

                if entry.id != self.history.last?.id {
                    Divider().overlay(self.style.background(.border))
                }

            }

        }

    }

}

#Preview {

    ScrollView {

        StoreAccountHistoryView(
            history: Array(MockCustomerModels.loyaltyHistory.prefix(5)),
            isLoading: false,
            hasCompletedInitialLoad: true,
            hasMoreHistory: true,
            loadMoreAction: {}
        )
        .padding(.medium)

    }
    .withMockPreviews()

}
