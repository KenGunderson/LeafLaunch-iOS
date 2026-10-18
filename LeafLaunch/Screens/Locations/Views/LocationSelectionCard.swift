import SwiftUI

struct LocationSelectionCard: View {

    @Environment(\.style) private var style

    let location: BootstrapLocation
    let details: CustomerLocationDetails?
    let isLoading: Bool
    let isSelected: Bool
    let selectAction: () -> Void

    private var regionDescription: String {

        let country = self.location.countryCode.flatMap { Locale.current.localizedString(forRegionCode: $0) }
        return [self.details?.location.city, self.details?.location.region ?? self.location.region, self.details == nil ? country : nil]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

    }

    private var streetAddress: String {

        guard let details = self.details else { return "" }

        let street = [details.location.addressLine1, details.location.addressLine2, details.location.postalCode]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

        return street.isEmpty ? details.address : street

    }

    var body: some View {

        HStack(alignment: .top, spacing: self.style.spacing(.small2)) {

            storeIcon()
            locationInformation()
            selectionIndicator()

        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {

            if self.isSelected {

                self.style.palette(.link).view()
                    .opacity(0.08)

            }

        }
        .contentShape(Rectangle())
        .asButton(action: self.selectAction)
        .animation(.bouncy, value: self.isSelected)

    }

    @ViewBuilder
    private func storeIcon() -> some View {

        ImageSource.systemImage("storefront")
            .view(shouldResize: false)
            .appFont(with: .TITLE_5)
            .foregroundStyle(self.isSelected ? self.style.palette(.link) : self.style.textColor(.title))
            .frame(width: self.style.spacing(.extraLarge), height: self.style.spacing(.extraLarge))
            .background(self.isSelected ? self.style.background(.secondary) : self.style.background(.tertiary), in: Circle())

    }

    @ViewBuilder
    private func locationInformation() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(self.location.name)
                .appFont(with: .TITLE_3)
                .foregroundStyle(self.style.textColor(.title))

            address()
            openStatus()

        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func address() -> some View {

        if !self.regionDescription.isEmpty {

            Text(self.regionDescription)
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))

        }

        if !self.streetAddress.isEmpty {

            Text(self.streetAddress)
                .appFont(with: .BODY_1)
                .foregroundStyle(self.style.textColor(.body))

        }

    }

    @ViewBuilder
    private func openStatus() -> some View {

        if let details = self.details {

            HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small)) {

                ImageSource.systemImage("circle.fill")
                    .view(shouldResize: false)
                    .imageScale(.small)

                Text(details.openNow ? String(localized: "Open now") : String(localized: "Closed now"))

            }
            .appFont(with: .NOTE_1)
            .foregroundStyle(details.openNow ? self.style.palette(.success) : self.style.textColor(.body))
            .padding(.top, .extraSmall)

        } else {

            Text(self.isLoading
                 ? String(localized: "Loading store details…")
                 : String(localized: "Store details unavailable"))
                .appFont(with: .NOTE_1)
                .foregroundStyle(self.style.textColor(.body))
                .padding(.top, .extraSmall)

        }

    }

    @ViewBuilder
    private func selectionIndicator() -> some View {

        ImageSource.systemImage(self.isSelected ? "checkmark.circle.fill" : "circle")
            .view(shouldResize: false)
            .appFont(with: .TITLE_5)
            .foregroundStyle(self.isSelected ? self.style.palette(.link) : self.style.textColor(.placeholder))
            .padding(.top, .extraSmall)

    }

}

#Preview {

    if let location = MockCustomerModels.bootstrap.locations.first {

        LocationSelectionCard(
            location: location,
            details: MockCustomerModels.locationDetails,
            isLoading: false,
            isSelected: true,
            selectAction: {}
        )
        .padding(.medium)
        .withMockPreviews()

    }

}
