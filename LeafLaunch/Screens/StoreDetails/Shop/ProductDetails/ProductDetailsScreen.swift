import SwiftUI

struct ProductDetailsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: ProductDetailsViewModel

    init(viewModel: ProductDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .none) {
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

    @ViewBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Product"),
            navButtonSize: self.style.spacing(.medium2) * 2,
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() },
            trailingNavButtons: self.viewModel.product == nil ? [] : [.heart(isFilled: self.viewModel.isFavorite)],
            trailingNavButtonsForegroundColor: self.viewModel.isFavorite ? self.style.accent : self.style.textColor(.title),
            trailingNavButtonsAction: { [weak viewModel] _ in viewModel?.toggleFavorite() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            if let product = self.viewModel.product {

                productDetails(product)

            } else if self.viewModel.isLoading {

                ProgressView(String(localized: "Loading product…"))
                    .appFont(with: .BODY_2)
                    .tint(self.style.foreground(.primary).resolvedColor(style: self.style))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .extraLarge)
                    .padding(.horizontal, .medium)

            } else if self.viewModel.hasLoadFailed {

                CommerceEmptyState(
                    systemImage: "cube.box",
                    title: String(localized: "Product Unavailable"),
                    message: String(localized: "We couldn't load this product. Try again to see its latest details.")
                )
                .padding(.horizontal, .medium)

            }

            retryAction()

        }
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func productDetails(_ product: Product) -> some View {

        ProductGalleryView(product: product)
            .padding(.horizontal, .medium)

        productInformation(product)

        if !product.attributes.isEmpty {

            ProductAttributesView(attributes: product.attributes)
                .padding(.horizontal, .medium)

        }

        contactActions()
            .padding(.horizontal, .medium)

        recommendedProducts()

    }

    @ViewBuilder
    private func productInformation(_ product: Product) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            ProductDetailsSummaryView(product: product)
                .padding(.horizontal, .medium)

            description(product)

            ProductOptionsView(product: product, contentInset: self.style.spacing(.medium))

        }

    }

    @ViewBuilder
    private func contactActions() -> some View {

        ProductContactView(
            storeName: self.viewModel.storeName,
            canOpenMaps: self.viewModel.canOpenMaps,
            canCallStore: self.viewModel.canCallStore,
            canEmailStore: self.viewModel.canEmailStore,
            onDirections: { self.viewModel.openMaps() },
            onCall: { self.viewModel.callStore() },
            onEmail: { self.viewModel.emailStore() }
        )

    }

    @ViewBuilder
    private func recommendedProducts() -> some View {

        if !self.viewModel.recommendedProducts.isEmpty {

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                CommerceSectionHeader(title: String(localized: "Recommended"))
                    .padding(.horizontal, .medium)

                recommendedCarousel()

            }

        }

    }

    @ViewBuilder
    private func recommendedCarousel() -> some View {

        ScrollView(.horizontal) {

            LazyHStack(alignment: .top, spacing: self.style.spacing(.small)) {

                ForEach(self.viewModel.recommendedProducts) { product in
                    recommendedProductCard(product)
                }

            }
            .scrollTargetLayout()

        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .safeAreaPadding(.horizontal, self.style.spacing(.medium))

    }

    @ViewBuilder
    private func recommendedProductCard(_ product: Product) -> some View {

        ProductCardView(
            product: product,
            isFavorite: self.viewModel.favoriteProductIds.contains(product.id),
            onOpen: { self.viewModel.openProduct(product) },
            onFavorite: { self.viewModel.toggleFavorite(product) }
        )
        .containerRelativeFrame(
            .horizontal,
            count: 2,
            span: 1,
            spacing: self.style.spacing(.small)
        )

    }

    @ViewBuilder
    private func retryAction() -> some View {

        if self.viewModel.product == nil && self.viewModel.hasLoadFailed {

            LeafLaunchButton(
                title: String(localized: "Try Again"),
                icon: .systemImage("arrow.clockwise")
            ) {
                self.viewModel.loadData(showHud: true)
            }
            .disabled(self.viewModel.isLoading)
            .padding(.horizontal, .medium)

        }

    }

    @ViewBuilder
    private func description(_ product: Product) -> some View {

        if let description = product.description?.trimmingCharacters(in: .whitespacesAndNewlines),
           !description.isEmpty {

            Text(description)
                .appFont(with: .BODY_2)
                .foregroundStyle(.text(.body))
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, .medium)

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
    .withMockPreviews()

}
