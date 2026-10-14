import SwiftUI

struct ProductDetailsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: ProductDetailsViewModel

    init(viewModel: ProductDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

        .task { [weak viewModel] in
            viewModel?.loadData(showHud: true)
        }

    }

    private func navHeader() -> some View {

        NavHeader(
            title: self.viewModel.product?.displayName ?? String(localized: "Product"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            if let product = self.viewModel.product {

                gallery(product: product)

                GroupBox(String(localized: "Description")) {

                    VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                        Text(product.displayName).appFont(with: .TITLE_4)
                        Text(product.description ?? String(localized: "No description available."))
                        Text([product.category?.name, product.subcategory?.name].compactMap { $0 }.joined(separator: " / "))

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                }

                attributes(product: product)
                pricing(product: product)

                LeafLaunchButton(title: self.viewModel.isFavorite ? String(localized: "Remove Favorite") : String(localized: "Favorite Product")) {
                    self.viewModel.toggleFavorite()
                }

            }

            LeafLaunchButton(title: String(localized: "Reload Product")) {
                self.viewModel.loadData(showHud: true)
            }
            .disabled(self.viewModel.isLoading)

        }
        .appFont(with: .BODY_2)
        .foregroundStyle(.text(.body))
        .tabFlowContentSpacing()

    }

    private func gallery(product: Product) -> some View {

        GroupBox(String(localized: "Image Gallery")) {

            ScrollView(.horizontal) {

                HStack(spacing: self.style.spacing(.small)) {

                    let media = (product.media ?? []).filter { $0.status == .active }
                        .sorted { $0.displayOrder < $1.displayOrder }

                    if media.isEmpty {
                        Text(String(localized: "No product images."))
                    }

                    ForEach(media, id: \.id) { image in

                        VStack(spacing: self.style.spacing(.small)) {

                            if let url = self.viewModel.imageURLs[image.id] {

                                ImageSource.remote(url: url, contentMode: .fit)
                                    .view()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 160)
                                    .accessibilityLabel(image.altText ?? product.displayName)

                            } else {

                                Text(self.viewModel.unavailableImageIds.contains(image.id) ? String(localized: "Image unavailable") : String(localized: "Loading image…"))
                                    .frame(width: 160, height: 160)
                                    .background(.background(.quaternary))

                            }

                            Text(image.altText ?? product.displayName)

                        }

                    }

                }

            }

        }

    }

    private func attributes(product: Product) -> some View {

        GroupBox(String(localized: "Attributes")) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                if product.attributes.isEmpty {
                    Text(String(localized: "No attributes provided."))
                }

                ForEach(product.attributes, id: \.id) { attribute in

                    HStack(alignment: .top) {

                        Text(attribute.name)
                        Spacer()
                        Text(attribute.displayValue)

                    }

                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    private func pricing(product: Product) -> some View {

        GroupBox(String(localized: "Pricing")) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                ForEach(product.variants, id: \.id) { variant in

                    VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                        Text(variant.name).appFont(with: .TITLE_4)

                        if let price = variant.displayPrice {
                            Text(price.formatted(.currency(code: product.currencyCode)))
                        } else {
                            Text(String(localized: "Price unavailable"))
                        }

                        if let basePrice = variant.baseDisplayPrice, basePrice != variant.displayPrice {

                            Text(basePrice.formatted(.currency(code: product.currencyCode)))
                                .strikethrough()

                        }

                        if variant.promotionId != nil {
                            Text(String(localized: "Promotion applied"))
                        }

                        Text(variant.availability == .available ? String(localized: "Available") : String(localized: "Currently unavailable"))
                        Divider()

                    }

                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

}

#Preview {

    ProductDetailsScreen(
        viewModel: mockResolve(ProductDetailsViewModel.self)
            .setup(
                locationId: MockCustomerModels.primaryLocationId,
                productId: MockCustomerModels.products(locationId: MockCustomerModels.primaryLocationId).first!.id
            )
    )
    .withMockServices()

}
