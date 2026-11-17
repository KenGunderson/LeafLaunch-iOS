import SwiftUI

struct StoreAccountHistoryRow: View {

    @Environment(\.style) private var style
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let entry: LoyaltyHistoryEntry

    private var signedPoints: String {

        let points = self.entry.pointsDelta.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !points.isEmpty, !points.hasPrefix("+"), !points.hasPrefix("-"), !points.hasPrefix("−") else { return points }
        return "+\(points)"

    }

    private var isDeduction: Bool {
        return self.signedPoints.hasPrefix("-") || self.signedPoints.hasPrefix("−")
    }

    private var entryTitle: String {

        switch self.entry.entryType {
        case .award: return String(localized: "Points Earned")
        case .redemption: return String(localized: "Redemption")
        case .correction: return String(localized: "Points Adjustment")
        case .reversal: return String(localized: "Points Reversal")
        }

    }

    private var entryIcon: String {

        switch self.entry.entryType {
        case .award: return "plus"
        case .redemption: return "gift"
        case .correction: return "slider.horizontal.3"
        case .reversal: return "arrow.uturn.backward"
        }

    }

    var body: some View {

        HStack(
            alignment: .center,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

            transactionIcon()

            if self.dynamicTypeSize.isAccessibilitySize {

                VStack(
                    alignment: .leading,
                    spacing: self.style.spacing(LLSpacing.groupedContent)
                ) {

                    transactionDetails()
                    points()

                }

            } else {

                transactionDetails()
                    .frame(maxWidth: .infinity, alignment: .leading)
                points()

            }

        }

    }

    @ContentBuilder
    private func transactionIcon() -> some View {

        RNImageSource.systemImage(self.entryIcon)
            .view(shouldResize: false)
            .runeFont(with: .TITLE_6)
            .foregroundStyle(RNColorSource.palette(.link))
            .frame(
                width: 44,
                height: 44
            )
            .background {
                Circle().runeFill(RNColorSource.palette(.link)).opacity(0.08)
            }

    }

    @ContentBuilder
    private func transactionDetails() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            Text(self.entry.customerReason.isEmpty ? self.entryTitle : self.entry.customerReason)
                .runeFont(with: .TITLE_3)
                .runeTextColor(.title)

            if let rewardTitle = self.entry.rewardTitleSnapshot, !rewardTitle.isEmpty {

                Text(rewardTitle)
                    .runeFont(with: .BODY_1)
                    .runeTextColor(.body)

            }

            Text(self.entry.createdAt.formatted(
                date: .abbreviated,
                time: .shortened
            ))
                .runeFont(with: .NOTE_1)
                .runeTextColor(.body)

        }
        .fixedSize(
            horizontal: false,
            vertical: true
        )

    }

    @ContentBuilder
    private func points() -> some View {

        VStack(
            alignment: .trailing,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            Text(self.signedPoints)
                .runeFont(with: .TITLE_4)
                .monospacedDigit()
                .foregroundStyle(self.isDeduction ? RNColorSource.palette(.destructive) : RNColorSource.palette(.link))

            Text(String(localized: "points"))
                .runeFont(with: .NOTE_1)
                .runeTextColor(.body)

        }
        .fixedSize(
            horizontal: true,
            vertical: false
        )

    }

}

#Preview {

    if let entry = MockCustomerModels.loyaltyHistory.first {

        StoreAccountHistoryRow(entry: entry)
            .runePadding(LLSpacing.pageInset)
            .withMockPreviews()

    }

}
