import SwiftUI

struct StoreNavHeader: View {

    @Environment(\.style) private var style

    let configuration: CustomerBootstrap?
    let subtitle: String
    var onSelectLocation: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil

    private var fallbackLogo: ImageSource {
        .image(ImageResource(name: BusinessConfig.logoAssetName, bundle: .main))
    }

    private var logo: ImageSource {

        guard let url = self.configuration?.branding?.iconURL ?? self.configuration?.branding?.logoURL else {
            return self.fallbackLogo
        }

        return .remote(
            url: url,
            contentMode: .fill,
            placeholder: AnyView(self.fallbackLogo.view().aspectRatio(contentMode: .fill))
        )

    }

    var body: some View {

        NavHeader(
            title: self.configuration?.publicName ?? String(localized: "Store"),
            subtitle: self.subtitle,
            subtitleAction: self.onSelectLocation,
            leadingImage: self.logo,
            trailingNavButtons: self.onDismiss == nil ? [] : [.close],
            trailingNavButtonsAction: { _ in self.onDismiss?() }
        )

    }

}

#Preview {

    StoreNavHeader(
        configuration: MockCustomerModels.bootstrap,
        subtitle: String(localized: "Choose a location")
    )
    .withMockPreviews()

}
