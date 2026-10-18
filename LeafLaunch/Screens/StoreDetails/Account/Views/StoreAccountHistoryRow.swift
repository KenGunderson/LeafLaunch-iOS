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
        case .award: return String(localized: "Points earned")
        case .redemption: return String(localized: "Redemption")
        case .correction: return String(localized: "Points adjustment")
        case .reversal: return String(localized: "Points reversal")
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

        HStack(alignment: .center, spacing: self.style.spacing(.small2)) {

            transactionIcon()

            if self.dynamicTypeSize.isAccessibilitySize {

                VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

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

    @ViewBuilder
    private func transactionIcon() -> some View {

        ImageSource.systemImage(self.entryIcon)
            .view(shouldResize: false)
            .appFont(with: .TITLE_6)
            .foregroundStyle(self.style.palette(.link))
            .frame(width: 44, height: 44)
            .background {
                Circle().fill(self.style.palette(.link)).opacity(0.08)
            }

    }

    @ViewBuilder
    private func transactionDetails() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(self.entry.customerReason.isEmpty ? self.entryTitle : self.entry.customerReason)
                .appFont(with: .TITLE_3)
                .foregroundStyle(self.style.textColor(.title))

            if let rewardTitle = self.entry.rewardTitleSnapshot, !rewardTitle.isEmpty {

                Text(rewardTitle)
                    .appFont(with: .BODY_1)
                    .foregroundStyle(self.style.textColor(.body))

            }

            Text(self.entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                .appFont(with: .NOTE_1)
                .foregroundStyle(self.style.textColor(.body))

        }
        .fixedSize(horizontal: false, vertical: true)

    }

    @ViewBuilder
    private func points() -> some View {

        VStack(alignment: .trailing, spacing: self.style.spacing(.extraSmall)) {

            Text(self.signedPoints)
                .appFont(with: .TITLE_4)
                .monospacedDigit()
                .foregroundStyle(self.isDeduction ? self.style.palette(.destructive) : self.style.palette(.link))

            Text(String(localized: "points"))
                .appFont(with: .NOTE_1)
                .foregroundStyle(self.style.textColor(.body))

        }
        .fixedSize(horizontal: true, vertical: false)

    }

}

#Preview {

    if let entry = MockCustomerModels.loyaltyHistory.first {

        StoreAccountHistoryRow(entry: entry)
            .padding(.medium)
            .withMockPreviews()

    }

}
