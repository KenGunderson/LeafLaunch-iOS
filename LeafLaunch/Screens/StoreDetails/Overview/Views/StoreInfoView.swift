import SwiftUI

struct StoreInfoView: View {

    @Environment(\.style) private var style

    let store: PublicStore?
    let details: CustomerLocationDetails?

    private func contactURL(scheme: String, value: String) -> URL? {

        var components = URLComponents()
        components.scheme = scheme
        components.path = value
        return components.url

    }

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            Text(String(localized: "Store Info"))
                .appFont(with: .TITLE_6)

            information()

        }
        .foregroundStyle(Color.black)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .medium)
        .padding(.vertical, .medium)
        .tabFlowContentSpacing()
        .background(Color.white)

    }

    @ViewBuilder
    private func information() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            address()
            openingHours()
            phoneNumber()
            email()

        }

    }

    @ViewBuilder
    private func address() -> some View {

        if let address = self.details?.address, !address.isEmpty {

            infoRow(title: String(localized: "Address"), systemImage: "mappin.circle.fill") {

                Text(address)
                    .appFont(with: .BODY_2)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)

            }

        }

    }

    @ViewBuilder
    private func openingHours() -> some View {

        if let details = self.details {

            infoRow(title: String(localized: "Store Hours"), systemImage: "clock.fill") {

                StoreHoursView(details: details)
                    .padding(.trailing, .large)

            }

        }

    }

    @ViewBuilder
    private func phoneNumber() -> some View {

        if let phone = self.store?.supportPhone?.trimmingCharacters(in: .whitespacesAndNewlines),
           !phone.isEmpty {

            infoRow(title: String(localized: "Phone Number"), systemImage: "phone.circle.fill") {
                contactValue(phone, scheme: "tel")
            }

        }

    }

    @ViewBuilder
    private func email() -> some View {

        if let email = self.store?.supportEmail?.trimmingCharacters(in: .whitespacesAndNewlines),
           !email.isEmpty {

            infoRow(title: String(localized: "Email"), systemImage: "envelope.fill") {
                contactValue(email, scheme: "mailto")
            }

        }

    }

    @ViewBuilder
    private func contactValue(_ value: String, scheme: String) -> some View {

        if let url = contactURL(scheme: scheme, value: value) {

            Link(destination: url) {

                Text(value)
                    .foregroundStyle(Color.black)
                    .fixedSize(horizontal: false, vertical: true)

            }
            .appFont(with: .BODY_2)

        } else {

            Text(value)
                .appFont(with: .BODY_2)
                .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func infoRow<Content: View>(title: String,
                                       systemImage: String,
                                       @ViewBuilder content: () -> Content) -> some View {

        HStack(alignment: .top, spacing: self.style.spacing(.small2)) {

            ImageSource.systemImage(systemImage)
                .view()
                .aspectRatio(contentMode: .fit)
                .frame(width: self.style.spacing(.medium), height: self.style.spacing(.medium))
                .foregroundStyle(Color(hex: "#CACFD2"))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                Text(title)
                    .appFont(with: .TITLE_3)

                content()

            }
            .frame(maxWidth: .infinity, alignment: .leading)

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
