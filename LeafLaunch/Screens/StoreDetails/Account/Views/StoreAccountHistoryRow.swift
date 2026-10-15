import SwiftUI

struct StoreAccountHistoryRow: View {

    @Environment(\.style) private var style
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let entry: LoyaltyHistoryEntry

    private var signedPoints: String {

        let points = self.entry.pointsDelta.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !points.isEmpty, !points.hasPrefix("+"), !points.hasPrefix("-"), !points.hasPrefix("−") else {
            return points
        }

        return "+\(points)"

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

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            if self.dynamicTypeSize.isAccessibilitySize {

                VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                    transactionTitle()
                    points()

                }

            } else {

                HStack(alignment: .top, spacing: self.style.spacing(.medium)) {

                    transactionTitle()
                    Spacer(minLength: 0)
                    points()

                }

            }

            if let rewardTitle = self.entry.rewardTitleSnapshot, !rewardTitle.isEmpty {

                Text(rewardTitle)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.title))

            }

            Text(self.entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                .appFont(with: .NOTE_1)
                .foregroundStyle(self.style.textColor(.body))

        }
        .padding(.vertical, self.style.spacing(.extraSmall))

    }

    private func transactionTitle() -> some View {

        HStack(alignment: .top, spacing: self.style.spacing(.small)) {

            ImageSource.systemImage(self.entryIcon).view(shouldResize: false)
                .appFont(with: .TITLE_3)
                .foregroundStyle(self.style.foreground(.primary))

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(self.entry.customerReason.isEmpty ? self.entryTitle : self.entry.customerReason)
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(self.style.textColor(.title))
                    .fixedSize(horizontal: false, vertical: true)

                Text(self.entryTitle)
                    .appFont(with: .BODY_1)
                    .foregroundStyle(self.style.textColor(.body))

            }

        }

    }

    private func points() -> some View {

        VStack(alignment: .trailing, spacing: self.style.spacing(.extraSmall)) {

            Text(self.signedPoints)
                .appFont(with: .TITLE_4)
                .monospacedDigit()
                .foregroundStyle(self.style.textColor(.title))

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
