import SwiftUI

struct LocationSelectionCard: View {

    @Environment(\.style) private var style

    let location: BootstrapLocation
    let details: CustomerLocationDetails?
    let isLoading: Bool
    let selectAction: () -> Void

    private var regionDescription: String {

        [self.location.region, countryName()]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

    }

    private func countryName() -> String? {

        guard let countryCode = self.location.countryCode, !countryCode.isEmpty else { return nil }
        return Locale.current.localizedString(forRegionCode: countryCode) ?? countryCode

    }

    var body: some View {

        CommerceSurface {

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                locationHeader()
                metadata()

                Divider().overlay(self.style.background(.border))
                actionLabel()

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())

        }
        .asButton(action: self.selectAction)

    }

    @ViewBuilder
    private func locationHeader() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(self.location.name)
                .appFont(with: .TITLE_5)
                .foregroundStyle(self.style.textColor(.title))
                .fixedSize(horizontal: false, vertical: true)

            if let details = self.details {

                HStack(spacing: self.style.spacing(.extraSmall)) {

                    ImageSource.systemImage(details.openNow ? "checkmark.circle.fill" : "clock")
                        .view(shouldResize: false)
                    Text(details.openNow ? String(localized: "Open now") : String(localized: "Closed now"))

                }
                .appFont(with: .NOTE_1)
                .foregroundStyle(details.openNow ? self.style.palette(.success) : self.style.textColor(.body))

            }

        }

    }

    @ViewBuilder
    private func metadata() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            if let details = self.details {

                if !details.address.isEmpty {
                    metadataLabel(details.address, systemImage: "mappin.and.ellipse")
                }

                metadataLabel(
                    String(localized: "Today: \(details.todayHoursDescription)"),
                    systemImage: "clock"
                )

            } else {

                if !self.regionDescription.isEmpty {
                    metadataLabel(self.regionDescription, systemImage: "mappin.and.ellipse")
                }

                metadataLabel(
                    self.isLoading
                        ? String(localized: "Loading address and hours…")
                        : String(localized: "Address and hours unavailable"),
                    systemImage: "clock"
                )

            }

        }

    }

    @ViewBuilder
    private func metadataLabel(_ text: String, systemImage: String) -> some View {

        HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small)) {

            ImageSource.systemImage(systemImage)
                .view(shouldResize: false)

            Text(text)
                .fixedSize(horizontal: false, vertical: true)

        }
        .appFont(with: .BODY_2)
        .foregroundStyle(self.style.textColor(.body))

    }

    @ViewBuilder
    private func actionLabel() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            Text(String(localized: "Open Location"))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            ImageSource.systemImage("chevron.right")
                .view(shouldResize: false)

        }
        .appFont(with: .TITLE_3)
        .foregroundStyle(self.style.foreground(.primary))

    }

}

#Preview {

    if let location = MockCustomerModels.bootstrap.locations.first {

        LocationSelectionCard(
            location: location,
            details: MockCustomerModels.locationDetails,
            isLoading: false,
            selectAction: {}
        )
        .padding(.medium)
        .withMockPreviews()

    }

}
