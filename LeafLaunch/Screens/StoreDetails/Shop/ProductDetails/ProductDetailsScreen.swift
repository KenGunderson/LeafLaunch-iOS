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
            title: String(localized: "Product"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            if let product = self.viewModel.product {

                ProductGalleryView(
                    product: product,
                    imageURLs: self.viewModel.imageURLs,
                    unavailableImageIds: self.viewModel.unavailableImageIds
                )

                ProductDetailsSummaryView(
                    product: product,
                    isFavorite: self.viewModel.isFavorite,
                    onFavorite: { self.viewModel.toggleFavorite() }
                )

                ProductOptionsView(product: product)
                description(product)

                if !product.attributes.isEmpty {
                    ProductAttributesView(attributes: product.attributes)
                }

            } else if self.viewModel.isLoading {

                ProgressView(String(localized: "Loading product…"))
                    .appFont(with: .BODY_2)
                    .tint(self.style.foreground(.primary).resolvedColor(style: self.style))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .extraLarge)

            } else if self.viewModel.hasLoadFailed {

                CommerceEmptyState(
                    systemImage: "cube.box",
                    title: String(localized: "Product unavailable"),
                    message: String(localized: "We couldn't load this product. Try again to see its latest details.")
                )

            }

            if self.viewModel.product == nil && self.viewModel.hasLoadFailed {

                LeafLaunchButton(
                    title: String(localized: "Try again"),
                    icon: .systemImage("arrow.clockwise")
                ) {
                    self.viewModel.loadData(showHud: true)
                }
                .disabled(self.viewModel.isLoading)

            }

        }
        .padding(.top, .small)
        .tabFlowContentSpacing()

    }

    private func description(_ product: Product) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            CommerceSectionHeader(title: String(localized: "About this product"))

            let description = product.description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            Text(description.isEmpty ? String(localized: "No description available.") : description)
                .appFont(with: .BODY_2)
                .foregroundStyle(.text(.body))
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)

        }
        .frame(maxWidth: .infinity, alignment: .leading)

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
    .withMockPreviews()

}
