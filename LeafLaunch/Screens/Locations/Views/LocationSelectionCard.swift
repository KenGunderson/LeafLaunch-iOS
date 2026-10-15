import SwiftUI

struct LocationSelectionCard: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let location: BootstrapLocation
    let selectAction: () -> Void

    private var regionDescription: String {

        [self.location.region, countryName()]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

    }

    private var timezoneDescription: String? {

        guard let timezone = self.location.timezone, !timezone.isEmpty else { return nil }
        return TimeZone(identifier: timezone)?.localizedName(for: .generic, locale: .current) ?? timezone

    }

    private func countryName() -> String? {

        guard let countryCode = self.location.countryCode, !countryCode.isEmpty else { return nil }
        return Locale.current.localizedString(forRegionCode: countryCode) ?? countryCode

    }

    var body: some View {

        CommerceSurface {

            VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                Text(self.location.name)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(self.style.textColor(.title))
                    .fixedSize(horizontal: false, vertical: true)

                metadata()

                Divider().overlay(self.style.background(.border))
                actionLabel()

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())

        }
        .asButton(scale: self.reduceMotion ? 1 : nil, action: self.selectAction)
        .accessibilityElement(children: .combine)

    }

    @ViewBuilder
    private func metadata() -> some View {

        if !self.regionDescription.isEmpty || self.timezoneDescription != nil {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                if !self.regionDescription.isEmpty {
                    metadataLabel(self.regionDescription, systemImage: "mappin.and.ellipse")
                }

                if let timezoneDescription {
                    metadataLabel(timezoneDescription, systemImage: "clock")
                }

            }

        }

    }

    private func metadataLabel(_ text: String, systemImage: String) -> some View {

        HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small)) {

            ImageSource.systemImage(systemImage)
                .view(shouldResize: false)
                .accessibilityHidden(true)

            Text(text)
                .fixedSize(horizontal: false, vertical: true)

        }
        .appFont(with: .BODY_1)
        .foregroundStyle(self.style.textColor(.body))

    }

    private func actionLabel() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            Text(String(localized: "Open Location"))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            ImageSource.systemImage("arrow.up.right")
                .view(shouldResize: false)
                .accessibilityHidden(true)

        }
        .appFont(with: .TITLE_3)
        .foregroundStyle(self.style.foreground(.primary))
        .padding(.vertical, self.style.spacing(.small))
        .frame(minHeight: 44)

    }

}

#Preview {

    if let location = MockCustomerModels.bootstrap.locations.first {

        LocationSelectionCard(location: location, selectAction: {})
            .padding(.medium)
            .withMockPreviews()

    }

}
