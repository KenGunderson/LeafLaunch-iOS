import SwiftUI

struct ProductContactView: View {

    @Environment(\.style) private var style

    let storeName: String
    let canOpenMaps: Bool
    let canCallStore: Bool
    let onDirections: () -> Void
    let onCall: () -> Void

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

            Text(String(localized: "Questions about this product?"))
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

        HStack(spacing: self.style.spacing(.small)) {

            LeafLaunchButton(
                title: String(localized: "Directions"),
                icon: .systemImage("map.fill"),
                isEnabled: self.canOpenMaps,
                action: self.onDirections
            )

            CommonButton(
                style: .outline(lineWidth: 1),
                title: String(localized: "Call store"),
                titleColor: self.style.foreground(.primary),
                icon: .systemImage("phone.fill"),
                backgroundStyle: self.style.foreground(.primary),
                isEnabled: self.canCallStore,
                verticalPadding: .small2,
                cornerRadius: .medium,
                action: self.onCall
            )

        }

    }

}

#Preview {

    ProductContactView(
        storeName: MockCustomerModels.locationDetails.location.name,
        canOpenMaps: true,
        canCallStore: true,
        onDirections: {},
        onCall: {}
    )
    .padding(.medium)
    .withMockPreviews()

}
