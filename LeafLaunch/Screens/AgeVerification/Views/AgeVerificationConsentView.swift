import SwiftUI

struct AgeVerificationConsentView: View {

    @Environment(\.style) private var style

    let minimumAge: Int
    let locationDetails: CustomerLocationDetails?
    let changeLocationAction: () -> Void

    private var regionDescription: String {

        [self.locationDetails?.location.city, self.locationDetails?.location.region]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")

    }

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            ageRequirement()
            location()

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func ageRequirement() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            ageBadge()
            ageConfirmation()

        }
        .padding(.horizontal, .small)

    }

    @ViewBuilder
    private func ageBadge() -> some View {

        Text("\(self.minimumAge)+")
            .appFont(with: .BILLBOARD_3)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(self.style.palette(.link))
            .frame(
                width: self.style.spacing(.extraLarge2) * 2,
                height: self.style.spacing(.extraLarge2) * 2
            )
            .background {

                self.style.palette(.link).view()
                    .opacity(0.08)

            }
            .cornerRadius(.extraLarge)

    }

    @ViewBuilder
    private func ageConfirmation() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            Text(String(localized: "Age Confirmation"))
                .appFont(with: .TITLE_2)
                .foregroundStyle(self.style.textColor(.body))

            confirmationCopy()

        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func confirmationCopy() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            Text(String(localized: "Adults Only."))
                .appFont(with: .BILLBOARD_2)
                .foregroundStyle(self.style.textColor(.title))

            Text(String(localized: "Please confirm you're \(self.minimumAge) or older to continue."))
                .appFont(with: .BODY_3)
                .foregroundStyle(self.style.textColor(.body))

        }

    }

    @ViewBuilder
    private func location() -> some View {

        if let details = self.locationDetails {

            LLAppCardView(verticalPadding: .small2, horizontalPadding: .medium, cornerRadius: .medium2) {

                HStack(spacing: self.style.spacing(.medium)) {

                    locationIcon()
                    locationInformation(details)
                    changeLocation()

                }

            }
            .contentShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
            .asButton(action: self.changeLocationAction)

        }

    }

    @ViewBuilder
    private func locationIcon() -> some View {

        ImageSource.systemImage("mappin")
            .view(shouldResize: false)
            .appFont(with: .HEADER_4)
            .foregroundStyle(self.style.palette(.link))
            .frame(width: self.style.spacing(.large2))

    }

    @ViewBuilder
    private func locationInformation(_ details: CustomerLocationDetails) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(details.location.name)
                .appFont(with: .TITLE_4)
                .foregroundStyle(self.style.textColor(.title))

            let address = self.regionDescription.isEmpty ? details.address : self.regionDescription

            if !address.isEmpty {

                Text(address)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.body))

            }

        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func changeLocation() -> some View {

        HStack(spacing: self.style.spacing(.small2)) {

            Text(String(localized: "Change"))
                .appFont(with: .BODY_2)

            ImageSource.systemImage("chevron.right")
                .view(shouldResize: false)
                .appFont(with: .TITLE_3)

        }
        .foregroundStyle(self.style.palette(.link))
        .fixedSize(horizontal: true, vertical: false)

    }

}

#Preview {

    let details = MockCustomerModels.locationDetails

    AgeVerificationConsentView(
        minimumAge: details.agePolicy.minimumAge,
        locationDetails: details,
        changeLocationAction: {}
    )
    .padding(.medium)
    .withMockPreviews()

}
