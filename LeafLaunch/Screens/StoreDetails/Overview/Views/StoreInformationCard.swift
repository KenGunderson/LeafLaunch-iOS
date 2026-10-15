import SwiftUI

struct StoreInformationCard: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showsContact = false

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

            CommerceSectionHeader(title: String(localized: "Plan your visit"))

            CommerceSurface {

                VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                    if let details = self.details {
                        StoreHoursDisclosure(details: details)
                    }

                    if self.details != nil && self.store != nil {
                        Divider()
                    }

                    if let store = self.store {
                        contactDisclosure(store)
                    }

                }

            }

        }
        .animation(self.reduceMotion ? nil : .bouncy, value: self.showsContact)

    }

    private func contactDisclosure(_ store: PublicStore) -> some View {

        DisclosureGroup(isExpanded: self.$showsContact) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                Text(store.name)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(.text(.title))

                if let legalName = store.legalName, legalName != store.name, !legalName.isEmpty {

                    Text(legalName)
                        .appFont(with: .NOTE_1)
                        .foregroundStyle(.text(.body))

                }

                if let phone = store.supportPhone, !phone.isEmpty {

                    if let url = contactURL(scheme: "tel", value: phone) {

                        Link(destination: url) {
                            contactLabel(phone, systemImage: "phone")
                        }

                    } else {
                        contactLabel(phone, systemImage: "phone")
                    }

                }

                if let email = store.supportEmail, !email.isEmpty {

                    if let url = contactURL(scheme: "mailto", value: email) {

                        Link(destination: url) {
                            contactLabel(email, systemImage: "envelope")
                        }

                    } else {
                        contactLabel(email, systemImage: "envelope")
                    }

                }

                if let websiteURL = store.websiteURL {

                    Link(destination: websiteURL) {
                        contactLabel(String(localized: "Business Website"), systemImage: "globe")
                    }

                }

            }
            .padding(.top, .small2)

        } label: {
            disclosureLabel(String(localized: "Contact & store details"), systemImage: "info.circle")
        }
        .tint(self.style.foreground(.primary).source(style: self.style))

    }

    private func disclosureLabel(_ title: String, systemImage: String) -> some View {

        HStack(spacing: self.style.spacing(.small2)) {

            ImageSource.systemImage(systemImage)
                .view(shouldResize: false)
                .foregroundStyle(.foreground(.primary))
                .accessibilityHidden(true)
            Text(title)
                .foregroundStyle(.text(.title))

        }
        .appFont(with: .TITLE_3)
        .padding(.vertical, .small)
        .frame(minHeight: 44)

    }

    private func contactLabel(_ title: String, systemImage: String) -> some View {

        HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small2)) {

            ImageSource.systemImage(systemImage)
                .view(shouldResize: false)
                .accessibilityHidden(true)
            Text(title)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)

        }
        .appFont(with: .BODY_2)
        .foregroundStyle(.foreground(.primary))
        .padding(.vertical, .small)
        .frame(minHeight: 44)

    }

}

#Preview {

    ScrollView {

        StoreInformationCard(store: MockCustomerModels.store, details: MockCustomerModels.locationDetails)
            .padding(.medium)

    }
    .withMockPreviews()

}
