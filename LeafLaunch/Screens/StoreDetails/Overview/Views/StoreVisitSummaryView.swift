import SwiftUI

struct StoreVisitSummaryView: View {

    @Environment(\.style) private var style

    let details: CustomerLocationDetails
    let onSelect: () -> Void

    var body: some View {

        LLAppCardView(cornerRadius: .large) {

            HStack(spacing: self.style.spacing(.medium)) {

                visitDetails()

                ImageSource.systemImage("chevron.down")
                    .view(shouldResize: false)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(self.style.palette(.link))

            }

        }
        .asButton(action: self.onSelect)

    }

    @ViewBuilder
    private func visitDetails() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            status()

            Text(String(localized: "Today: \(self.details.todayHoursDescription)"))
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))
                .fixedSize(horizontal: false, vertical: true)

            Text(String(localized: "Hours & Directions"))
                .appFont(with: .TITLE_2)
                .foregroundStyle(self.style.palette(.link))
                .padding(.top, .small)

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func status() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            Circle()
                .fill(self.details.openNow ? self.style.palette(.link) : self.style.textColor(.body))
                .frame(width: 6, height: 6)

            Text(self.details.openNow ? String(localized: "Open Now") : String(localized: "Closed Now"))
                .appFont(with: .TITLE_3)
                .foregroundStyle(self.style.textColor(.title))

        }

    }

}

#Preview {

    StoreVisitSummaryView(details: MockCustomerModels.locationDetails, onSelect: {})
        .padding(.medium)
        .withMockPreviews()

}
