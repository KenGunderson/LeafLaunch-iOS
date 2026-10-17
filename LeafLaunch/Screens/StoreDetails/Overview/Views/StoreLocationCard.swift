import SwiftUI

struct StoreLocationCard: View {

    @Environment(\.style) private var style

    let details: CustomerLocationDetails
    let onChangeLocation: () -> Void

    var body: some View {

        CommerceSurface {

            VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                locationHeader()
                address()
                Divider()
                changeLocationAction()

            }

        }

    }

    @ViewBuilder
    private func locationLabel() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            ImageSource.systemImage("mappin.and.ellipse")
                .view(shouldResize: false)
            Text(String(localized: "Your location"))

        }
        .appFont(with: .TITLE_2)
        .foregroundStyle(.text(.body))

    }

    @ViewBuilder
    private func openStatus() -> some View {

        HStack(spacing: self.style.spacing(.extraSmall)) {

            ImageSource.systemImage(self.details.openNow ? "checkmark.circle.fill" : "clock")
                .view(shouldResize: false)
            Text(self.details.openNow ? String(localized: "Open now") : String(localized: "Closed now"))

        }
        .appFont(with: .TITLE_2)
        .foregroundStyle(self.details.openNow ? .palette(.success) : .text(.body))
        .fixedSize(horizontal: false, vertical: true)

    }

    @ViewBuilder
    private func locationHeader() -> some View {

        ViewThatFits(in: .horizontal) {

            HStack(spacing: self.style.spacing(.small)) {

                locationLabel()
                Spacer(minLength: self.style.spacing(.small))
                openStatus()

            }

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                locationLabel()
                openStatus()

            }

        }

    }

    @ViewBuilder
    private func address() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            Text(self.details.location.name)
                .appFont(with: .HEADER_4)
                .foregroundStyle(.text(.title))
                .fixedSize(horizontal: false, vertical: true)

            if !self.details.mapsAddress.isEmpty {

                Text(self.details.mapsAddress)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(.text(.body))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)

            }

        }

    }

    @ViewBuilder
    private func changeLocationAction() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            Text(String(localized: "Change Location"))
            Spacer(minLength: self.style.spacing(.small))
            ImageSource.systemImage("arrow.left.arrow.right")
                .view(shouldResize: false)

        }
        .appFont(with: .TITLE_3)
        .foregroundStyle(.foreground(.primary))
        .padding(.vertical, .small)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
        .asButton(action: self.onChangeLocation)

    }

}

#Preview {

    StoreLocationCard(details: MockCustomerModels.locationDetails, onChangeLocation: {})
        .padding(.medium)
        .withMockPreviews()

}
