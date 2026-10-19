import SwiftUI

struct ProductContactView: View {

    @Environment(\.style) private var style

    let storeName: String
    let canOpenMaps: Bool
    let canCallStore: Bool
    let canEmailStore: Bool
    let onDirections: () -> Void
    let onCall: () -> Void
    let onEmail: () -> Void

    var body: some View {

        LLAppCardView(cornerRadius: .medium2) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                heading()
                contactActions()

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    @ViewBuilder
    private func heading() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(String(localized: "Questions About This Product?"))
                .appFont(with: .TITLE_5)
                .foregroundStyle(self.style.textColor(.title))
                .fixedSize(horizontal: false, vertical: true)

            if !self.storeName.isEmpty {

                Text(self.storeName)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.body))
                    .fixedSize(horizontal: false, vertical: true)

            }

        }

    }

    @ViewBuilder
    private func contactActions() -> some View {

        HStack(spacing: self.style.spacing(.extraSmall)) {

            LeafLaunchButton(
                title: String(localized: "Map"),
                titleFont: .TITLE_3,
                icon: .systemImage("map.fill"),
                isEnabled: self.canOpenMaps,
                action: self.onDirections
            )
            .frame(maxWidth: .infinity)

            LeafLaunchButton(
                title: String(localized: "Call"),
                titleFont: .TITLE_3,
                icon: .systemImage("phone.fill"),
                isEnabled: self.canCallStore,
                action: self.onCall
            )
            .frame(maxWidth: .infinity)

            LeafLaunchButton(
                title: String(localized: "Email"),
                titleFont: .TITLE_3,
                icon: .systemImage("envelope.fill"),
                isEnabled: self.canEmailStore,
                action: self.onEmail
            )
            .frame(maxWidth: .infinity)

        }
        .appFont(with: .TITLE_3)

    }

}

#Preview {

    ProductContactView(
        storeName: MockCustomerModels.locationDetails.location.name,
        canOpenMaps: true,
        canCallStore: true,
        canEmailStore: true,
        onDirections: {},
        onCall: {},
        onEmail: {}
    )
    .padding(.medium)
    .withMockPreviews()

}
