import SwiftUI

struct StoreNavHeader: View {

    @Environment(\.style) private var style

    let configuration: CustomerBootstrap?
    let subtitle: String?
    var status: String? = nil
    var isOpen: Bool? = nil
    var onBack: (() -> Void)? = nil
    var onSelectLocation: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    var onFavorites: (() -> Void)? = nil

    private var trailingButtons: [NavBarButton.Style] {

        var buttons: [NavBarButton.Style] = []
        if self.onFavorites != nil { buttons.append(.storeFavorites) }
        if self.onDismiss != nil { buttons.append(.close) }
        return buttons

    }

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
            status: self.status,
            statusColor: self.isOpen == true ? .palette(.link) : .text(.body),
            leadingImage: self.logo,
            leadingNavButtons: self.onBack == nil ? [] : [.plainBack],
            leadingNavButtonsAction: { _ in self.onBack?() },
            trailingNavButtons: self.trailingButtons,
            trailingNavButtonsAction: { button in

                switch button {
                case .storeFavorites: self.onFavorites?()
                case .close: self.onDismiss?()
                default: break
                }

            }
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
