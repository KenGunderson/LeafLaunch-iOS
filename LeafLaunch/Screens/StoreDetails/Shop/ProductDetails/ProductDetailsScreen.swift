import SwiftUI

struct ProductDetailsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: ProductDetailsViewModel

    init(viewModel: ProductDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        LLAppHeaderScrollView(
            horizontalPadding: .none,
            onRefresh: { [weak viewModel] in await viewModel?.refreshData() }
        ) {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }
        .task { [weak viewModel] in
            viewModel?.loadData(showHud: self.viewModel.isFirstLoad)
        }

    }

    @ContentBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Product"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() },
            trailingNavButtons: self.viewModel.product == nil ? [] : [.heart(isFilled: self.viewModel.isFavorite)],
            trailingNavButtonsForegroundColor: self.viewModel.isFavorite ? RNColorSource.foreground(.primary) : RNColorSource.text(.title),
            trailingNavButtonsAction: { [weak viewModel] _ in viewModel?.toggleFavorite() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            if let product = self.viewModel.product {

                productDetails(product)

            } else if self.viewModel.isLoading {

                ProgressView(String(localized: "Loading Product…"))
                    .runeFont(with: .BODY_2)
                    .runeTint(.primary)
                    .frame(maxWidth: .infinity)
                    .runePadding(.vertical, .extraLarge)
                    .runePadding(.horizontal, LLSpacing.pageInset)

            } else if self.viewModel.hasLoadFailed {

                CommerceEmptyState(
                    systemImage: "cube.box",
                    title: String(localized: "Product Unavailable"),
                    message: String(localized: "We couldn't load this product. Try again to see its latest details.")
                )
                .runePadding(.horizontal, LLSpacing.pageInset)

            }

            retryAction()

        }
        .tabFlowContentSpacing()

    }

    @ContentBuilder
    private func productDetails(_ product: Product) -> some View {

        ProductGalleryView(product: product)
            .runePadding(.horizontal, LLSpacing.pageInset)

        productInformation(product)

        if !product.attributes.isEmpty {

            ProductAttributesView(attributes: product.attributes)
                .runePadding(.horizontal, LLSpacing.pageInset)

        }

        contactActions()
            .runePadding(.horizontal, LLSpacing.pageInset)

        recommendedProducts()

    }

    @ContentBuilder
    private func productInformation(_ product: Product) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            ProductDetailsSummaryView(product: product)
                .runePadding(.horizontal, LLSpacing.pageInset)

            description(product)

            ProductOptionsView(
                product: product,
                contentInset: self.style.spacing(LLSpacing.listRow)
            )
            .runePadding(.top, LLSpacing.groupedContent)

        }

    }

    @ContentBuilder
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

    @ContentBuilder
    private func recommendedProducts() -> some View {

        if !self.viewModel.recommendedProducts.isEmpty {

            LLSection(
                title: String(localized: "Recommended"),
                headingHorizontalPadding: LLSpacing.pageInset
            ) {

                recommendedCarousel()

            }

        }

    }

    @ContentBuilder
    private func recommendedCarousel() -> some View {

        ScrollView(.horizontal) {

            LazyHStack(
                alignment: .top,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                ForEach(self.viewModel.recommendedProducts) { product in
                    recommendedProductCard(product)
                }

            }
            .scrollTargetLayout()

        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .safeAreaPadding(
            .horizontal,
            self.style.spacing(LLSpacing.listRow)
        )

    }

    @ContentBuilder
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
            spacing: self.style.spacing(LLSpacing.groupedContent)
        )

    }

    @ContentBuilder
    private func retryAction() -> some View {

        if self.viewModel.product == nil && self.viewModel.hasLoadFailed {

            LeafLaunchButton(
                title: String(localized: "Try Again"),
                icon: .systemImage("arrow.clockwise")
            ) {
                self.viewModel.loadData(showHud: true)
            }
            .disabled(self.viewModel.isLoading)
            .runePadding(.horizontal, LLSpacing.pageInset)

        }

    }

    @ContentBuilder
    private func description(_ product: Product) -> some View {

        if let description = product.description?.trimmingCharacters(in: .whitespacesAndNewlines),
           !description.isEmpty {

            Text(description)
                .runeFont(with: .BODY_2)
                .runeTextColor(.body)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .runePadding(.horizontal, LLSpacing.pageInset)

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
