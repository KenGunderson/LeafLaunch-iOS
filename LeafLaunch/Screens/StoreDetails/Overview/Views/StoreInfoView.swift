import SwiftUI

struct StoreInfoView: View {

    @Environment(\.style) private var style

    let store: PublicStore?
    let details: CustomerLocationDetails?

    private var address: String? {

        guard let address = self.details?.address.trimmingCharacters(in: .whitespacesAndNewlines),
              !address.isEmpty else { return nil }

        return address

    }

    private var phone: String? {

        guard let phone = self.store?.supportPhone?.trimmingCharacters(in: .whitespacesAndNewlines),
              !phone.isEmpty else { return nil }

        return phone

    }

    private var email: String? {

        guard let email = self.store?.supportEmail?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else { return nil }

        return email

    }

    private var directionsURL: URL? {

        guard let address = self.address else { return nil }

        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [URLQueryItem(name: "q", value: address)]
        return components?.url

    }

    private func contactURL(scheme: String, value: String) -> URL? {

        var components = URLComponents()
        components.scheme = scheme
        components.path = value
        return components.url

    }

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            openingHours()
            contactDetails()

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .medium)
        .padding(.top, .large)
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func openingHours() -> some View {

        if let details = self.details {

            CommerceSurface {
                StoreHoursView(details: details)
            }

        }

    }

    @ViewBuilder
    private func contactDetails() -> some View {

        if self.address != nil || self.phone != nil || self.email != nil {

            CommerceSurface {

                VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                    Text(String(localized: "Get In Touch"))
                        .appFont(with: LeafLaunchThemeTokens.headingFont)
                        .foregroundStyle(self.style.textColor(.title))

                    contactRows()

                }

            }

        }

    }

    @ViewBuilder
    private func contactRows() -> some View {

        if let address = self.address {

            contactRow(
                title: String(localized: "Find Us"),
                value: address,
                url: self.directionsURL,
                systemImage: "mappin.and.ellipse"
            )

            if self.phone != nil || self.email != nil {
                LLDivider()
            }

        }

        if let phone = self.phone {

            contactRow(
                title: String(localized: "Call The Store"),
                value: phone,
                url: contactURL(scheme: "tel", value: phone),
                systemImage: "phone"
            )

            if self.email != nil {
                LLDivider()
            }

        }

        if let email = self.email {

            contactRow(
                title: String(localized: "Email The Store"),
                value: email,
                url: contactURL(scheme: "mailto", value: email),
                systemImage: "envelope"
            )

        }

    }

    @ViewBuilder
    private func contactRow(title: String,
                            value: String,
                            url: URL?,
                            systemImage: String) -> some View {

        if let url {

            Link(destination: url) {

                StoreInfoActionRow(
                    title: title,
                    value: value,
                    systemImage: systemImage
                )

            }
            .buttonStyle(.plain)

        } else {

            StoreInfoActionRow(
                title: title,
                value: value,
                systemImage: systemImage,
                showsChevron: false
            )

        }

    }

}

#Preview {

    ScrollView {

        StoreInfoView(
            store: MockCustomerModels.store,
            details: MockCustomerModels.locationDetails
        )

    }
    .withMockPreviews()

}
