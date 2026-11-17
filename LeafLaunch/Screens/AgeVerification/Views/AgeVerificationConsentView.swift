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

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            ageRequirement()
            location()

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func ageRequirement() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            ageBadge()
            ageConfirmation()

        }
        .runePadding(.horizontal, LLSpacing.groupedContent)

    }

    @ContentBuilder
    private func ageBadge() -> some View {

        Text("\(self.minimumAge)+")
            .runeFont(with: .BILLBOARD_3)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(RNColorSource.palette(.link))
            .frame(
                width: self.style.spacing(.extraLarge2) * 2,
                height: self.style.spacing(.extraLarge2) * 2
            )
            .background {

                RNColorSource.palette(.link).view()
                    .opacity(0.08)

            }
            .runeCornerRadius(.extraLarge)

    }

    @ContentBuilder
    private func ageConfirmation() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

            Text(String(localized: "Age Confirmation"))
                .runeFont(with: .TITLE_2)
                .runeTextColor(.body)

            confirmationCopy()

        }
        .fixedSize(
            horizontal: false,
            vertical: true
        )
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func confirmationCopy() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            Text(String(localized: "Adults Only."))
                .runeFont(with: .BILLBOARD_2)
                .runeTextColor(.title)

            Text(String(localized: "Please confirm you're \(self.minimumAge) or older to continue."))
                .runeFont(with: .BODY_3)
                .runeTextColor(.body)

        }

    }

    @ContentBuilder
    private func location() -> some View {

        if let details = self.locationDetails {

            LLAppCardView(
                verticalPadding: .small2,
                horizontalPadding: .medium,
                cornerRadius: .medium2
            ) {

                HStack(spacing: self.style.spacing(LLSpacing.listRow)) {

                    locationIcon()
                    locationInformation(details)
                    changeLocation()

                }

            }
            .contentShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
            .runeAsButton(action: self.changeLocationAction)

        }

    }

    @ContentBuilder
    private func locationIcon() -> some View {

        RNImageSource.systemImage("mappin")
            .view(shouldResize: false)
            .runeFont(with: .HEADER_4)
            .foregroundStyle(RNColorSource.palette(.link))
            .frame(width: self.style.spacing(.large2))

    }

    @ContentBuilder
    private func locationInformation(_ details: CustomerLocationDetails) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            Text(details.location.name)
                .runeFont(with: .TITLE_4)
                .runeTextColor(.title)

            let address = self.regionDescription.isEmpty ? details.address : self.regionDescription

            if !address.isEmpty {

                Text(address)
                    .runeFont(with: .BODY_2)
                    .runeTextColor(.body)

            }

        }
        .fixedSize(
            horizontal: false,
            vertical: true
        )
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func changeLocation() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            Text(String(localized: "Change"))
                .runeFont(with: .BODY_2)

            RNImageSource.systemImage("chevron.right")
                .view(shouldResize: false)
                .runeFont(with: .TITLE_3)

        }
        .foregroundStyle(RNColorSource.palette(.link))
        .fixedSize(
            horizontal: true,
            vertical: false
        )

    }

}

#Preview {

    let details = MockCustomerModels.locationDetails

    AgeVerificationConsentView(
        minimumAge: details.agePolicy.minimumAge,
        locationDetails: details,
        changeLocationAction: {}
    )
    .runePadding(LLSpacing.pageInset)
    .withMockPreviews()

}
