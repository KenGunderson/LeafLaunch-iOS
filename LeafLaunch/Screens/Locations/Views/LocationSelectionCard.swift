import SwiftUI

struct LocationSelectionCard: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

        LLAppCardView(
            verticalPadding: .none,
            horizontalPadding: .none,
            cornerRadius: .large,
            borderColor: self.isSelected ? RNColorSource.palette(.link) : nil
        ) {

            HStack(
                alignment: .top,
                spacing: self.style.spacing(LLSpacing.cardContent)
            ) {

                storeIcon()
                locationInformation()
                selectionIndicator()

            }
            .runePadding(LLSpacing.pageInset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {

                if self.isSelected {

                    RNColorSource.palette(.link).view()
                        .opacity(0.08)

                }

            }
            .runeCornerRadius(.large)

        }
        .contentShape(Rectangle())
        .runeAsButton(action: self.selectAction)
        .animation(
            .bouncy,
            value: self.isSelected
        )

    }

    @ContentBuilder
    private func storeIcon() -> some View {

        RNImageSource.systemImage("storefront")
            .view(shouldResize: false)
            .runeFont(with: .TITLE_5)
            .foregroundStyle(self.isSelected ? RNColorSource.color(.white) : RNColorSource.text(.title))
            .frame(
                width: self.style.spacing(.extraLarge),
                height: self.style.spacing(.extraLarge)
            )
            .background(
                self.isSelected ? RNColorSource.palette(.link) : RNColorSource.background(.tertiary),
                in: Circle()
            )

    }

    @ContentBuilder
    private func locationInformation() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            Text(self.location.name)
                .runeFont(with: .TITLE_3)
                .runeTextColor(.title)

            address()
            openStatus()
                .animation(
                    self.reduceMotion ? nil : .bouncy,
                    value: self.details?.openNow
                )

        }
        .fixedSize(
            horizontal: false,
            vertical: true
        )
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func address() -> some View {

        if !self.regionDescription.isEmpty {

            Text(self.regionDescription)
                .runeFont(with: .BODY_1)
                .runeTextColor(.body)

        }

        if !self.streetAddress.isEmpty {

            Text(self.streetAddress)
                .runeFont(with: .BODY_1)
                .runeTextColor(.body)

        }

    }

    @ContentBuilder
    private func openStatus() -> some View {

        if let details = self.details {

            HStack(
                alignment: .firstTextBaseline,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                RNImageSource.systemImage("circle.fill")
                    .view(shouldResize: false)
                    .imageScale(.small)

                Text(details.openNow ? String(localized: "Open Now") : String(localized: "Closed Now"))

            }
            .runeFont(with: .NOTE_1)
            .foregroundStyle(details.openNow ? RNColorSource.palette(.success) : RNColorSource.text(.body))
            .runePadding(.top, LLSpacing.metadata)
            .id(details.openNow)
            .transition(.blurReplace)

        } else {

            Text(self.isLoading
                 ? String(localized: "Loading Store Details…")
                 : String(localized: "Store Details Unavailable"))
                .runeFont(with: .NOTE_1)
                .runeTextColor(.body)
                .runePadding(.top, LLSpacing.metadata)
                .transition(.blurReplace)

        }

    }

    @ContentBuilder
    private func selectionIndicator() -> some View {

        RNImageSource.systemImage(self.isSelected ? "checkmark.circle.fill" : "circle")
            .view(shouldResize: false)
            .runeFont(with: .TITLE_5)
            .foregroundStyle(self.isSelected ? RNColorSource.palette(.link) : RNColorSource.text(.placeholder))
            .runePadding(.top, LLSpacing.metadata)

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
        .runePadding(LLSpacing.pageInset)
        .withMockPreviews()

    }

}
