import SwiftUI

struct AgeVerificationConsentView: View {

    @Environment(\.style) private var style

    let minimumAge: Int
    let locationDetails: CustomerLocationDetails?
    let isApproving: Bool
    let approveAction: () -> Void

    var body: some View {

        CommerceSurface {

            VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

                ageRequirement()

                location()
                approveActionView()

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    @ViewBuilder
    private func ageRequirement() -> some View {

        HStack(alignment: .top, spacing: self.style.spacing(.medium)) {

            Text("\(self.minimumAge)+")
                .appFont(with: .HEADER_2)
                .monospacedDigit()
                .foregroundStyle(self.style.foreground(.primary))
                .padding(.small2)
                .background(self.style.background(.tertiary))
                .cornerRadius(.medium2)

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(String(localized: "Confirm your age"))
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(self.style.textColor(.title))

                Text(String(localized: "You must be at least \(self.minimumAge) years old to continue."))
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.body))

            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    @ViewBuilder
    private func location() -> some View {

        if let details = self.locationDetails {

            Divider().overlay(self.style.background(.border))

            HStack(alignment: .top, spacing: self.style.spacing(.small2)) {

                ImageSource.systemImage("mappin.and.ellipse")
                    .view(shouldResize: false)
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(self.style.foreground(.primary))

                VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                    Text(details.location.name)
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(self.style.textColor(.title))

                    if !details.address.isEmpty {

                        Text(details.address)
                            .appFont(with: .BODY_2)
                            .foregroundStyle(self.style.textColor(.body))
                            .textSelection(.enabled)

                    }

                }
                .fixedSize(horizontal: false, vertical: true)

            }

        }

    }

    @ViewBuilder
    private func approveActionView() -> some View {

        LeafLaunchButton(title: String(localized: "I agree"), action: self.approveAction)
            .disabled(self.isApproving)

    }

}

#Preview {

    let details = MockCustomerModels.locationDetails

    AgeVerificationConsentView(
        minimumAge: details.agePolicy.minimumAge,
        locationDetails: details,
        isApproving: false,
        approveAction: {}
    )
    .padding(.medium)
    .withMockPreviews()

}
