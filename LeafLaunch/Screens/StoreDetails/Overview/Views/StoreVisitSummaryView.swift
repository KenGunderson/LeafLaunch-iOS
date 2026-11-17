import SwiftUI

struct StoreVisitSummaryView: View {

    @Environment(\.style) private var style

    let details: CustomerLocationDetails
    let onSelect: () -> Void

    var body: some View {

        LLAppCardView(cornerRadius: .large) {

            HStack(spacing: self.style.spacing(LLSpacing.listRow)) {

                visitDetails()

                RNImageSource.systemImage("chevron.down")
                    .view(shouldResize: false)
                    .runeFont(with: .TITLE_4)
                    .foregroundStyle(RNColorSource.palette(.link))

            }

        }
        .runeAsButton(action: self.onSelect)

    }

    @ContentBuilder
    private func visitDetails() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            status()

            Text(String(localized: "Today: \(self.details.todayHoursDescription)"))
                .runeFont(with: .BODY_1)
                .runeTextColor(.body)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Text(String(localized: "Hours & Directions"))
                .runeFont(with: .TITLE_2)
                .foregroundStyle(RNColorSource.palette(.link))
                .runePadding(.top, LLSpacing.groupedContent)

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func status() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            Circle()
                .runeFill(self.details.openNow ? RNColorSource.palette(.link) : RNColorSource.text(.body))
                .frame(
                    width: 6,
                    height: 6
                )

            Text(self.details.openNow ? String(localized: "Open Now") : String(localized: "Closed Now"))
                .runeFont(with: .TITLE_3)
                .runeTextColor(.title)

        }

    }

}

#Preview {

    StoreVisitSummaryView(
        details: MockCustomerModels.locationDetails,
        onSelect: {}
    )
        .runePadding(LLSpacing.pageInset)
        .withMockPreviews()

}
