import SwiftUI

struct AgeVerificationConsentView: View {

    @Environment(\.style) private var style

    let minimumAge: Int
    let stateName: String
    let isApproving: Bool
    let approveAction: () -> Void

    var body: some View {

        CommerceSurface {

            VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

                ageRequirement()

                Text(String(localized: "You must be at least \(self.minimumAge) years old to continue."))
                    .appFont(with: .HEADER_3)
                    .foregroundStyle(self.style.textColor(.title))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                if !self.stateName.isEmpty {
                    stateLabel()
                }

                Divider().overlay(self.style.background(.border))

                LeafLaunchButton(title: String(localized: "I agree"), action: self.approveAction)
                    .disabled(self.isApproving)

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    private func ageRequirement() -> some View {

        HStack(alignment: .center, spacing: self.style.spacing(.medium)) {

            ImageSource.systemImage("person.crop.square")
                .view(shouldResize: false)
                .appFont(with: .HEADER_3)
                .foregroundStyle(self.style.foreground(.primary))
                .padding(self.style.spacing(.medium))
                .background(self.style.background(.tertiary), in: Circle())

            Text("\(self.minimumAge)+")
                .appFont(with: .BILLBOARD_2)
                .monospacedDigit()
                .foregroundStyle(self.style.textColor(.title))

        }
        .accessibilityHidden(true)

    }

    private func stateLabel() -> some View {

        HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small)) {

            ImageSource.systemImage("mappin.and.ellipse")
                .view(shouldResize: false)
                .accessibilityHidden(true)

            Text(self.stateName)
                .fixedSize(horizontal: false, vertical: true)

        }
        .appFont(with: .BODY_2)
        .foregroundStyle(self.style.textColor(.body))

    }

}

#Preview {

    let details = MockCustomerModels.locationDetails

    AgeVerificationConsentView(
        minimumAge: details.agePolicy.minimumAge,
        stateName: details.location.region ?? "",
        isApproving: false,
        approveAction: {}
    )
    .padding(.medium)
    .withMockPreviews()

}
