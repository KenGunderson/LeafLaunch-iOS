import SwiftUI

struct StoreInfoView: View {

    @Environment(\.style) private var style

    let store: PublicStore?
    let details: CustomerLocationDetails?

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

        guard let address = self.details?.address, !address.isEmpty else { return nil }

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

        VStack(alignment: .leading, spacing: 0) {

            Text(String(localized: "Store Info"))
                .appFont(with: .TITLE_6)
                .foregroundStyle(self.style.textColor(.title))
                .padding(.bottom, .small2)

            location()
            openingHours()
            contactDetails()

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .medium)
        .padding(.vertical, .medium)
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func location() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            if let address = self.details?.address, !address.isEmpty {

                Text(address)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.title))
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)

            }

            contactActions()

        }

    }

    @ViewBuilder
    private func contactActions() -> some View {

        HStack(spacing: self.style.spacing(.small2)) {

            if let directionsURL = self.directionsURL {

                contactAction(
                    title: String(localized: "Directions"),
                    systemImage: "location.fill",
                    url: directionsURL,
                    isPrimary: true
                )

            }

            if let phone = self.phone,
               let url = contactURL(scheme: "tel", value: phone) {

                contactAction(
                    title: String(localized: "Call"),
                    systemImage: "phone.fill",
                    url: url,
                    isPrimary: false
                )

            }

        }

    }

    @ViewBuilder
    private func contactAction(title: String,
                               systemImage: String,
                               url: URL,
                               isPrimary: Bool) -> some View {

        Link(destination: url) {

            HStack(spacing: self.style.spacing(.small)) {

                ImageSource.systemImage(systemImage)
                    .view(shouldResize: false)

                Text(title)

            }
            .appFont(with: .TITLE_3)
            .foregroundStyle(isPrimary ? self.style.textColor(.button) : self.style.foreground(.primary))

        }
        .buttonStyle(.commonButtonStyle(
            style: isPrimary ? .fill : .outline(lineWidth: 1),
            background: isPrimary ? .foreground(.primary) : .background(.border),
            cornerRadius: .medium,
            verticalPadding: .small2,
            horizontalPadding: .small
        ))

    }

    @ViewBuilder
    private func openingHours() -> some View {

        if let details = self.details {

            sectionDivider()
            StoreHoursView(details: details)

        }

    }

    @ViewBuilder
    private func contactDetails() -> some View {

        if let email = self.email {

            sectionDivider()
            contactRow(
                title: String(localized: "Email the store"),
                value: email,
                scheme: "mailto",
                systemImage: "envelope"
            )

        }

        if let phone = self.phone {

            sectionDivider()
            contactRow(
                title: String(localized: "Phone number"),
                value: phone,
                scheme: "tel",
                systemImage: "phone.fill"
            )

        }

    }

    @ViewBuilder
    private func contactRow(title: String,
                            value: String,
                            scheme: String,
                            systemImage: String) -> some View {

        if let url = contactURL(scheme: scheme, value: value) {

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

    @ViewBuilder
    private func sectionDivider() -> some View {

        Divider()
            .overlay(self.style.background(.border))
            .padding(.vertical, .small2)

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
