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
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() },
            trailingNavButtons: self.viewModel.product == nil ? [] : [.heart(isFilled: self.viewModel.isFavorite)],
            trailingNavButtonsForegroundColor: self.viewModel.isFavorite ? self.style.accent : self.style.textColor(.title),
            trailingNavButtonsAction: { [weak viewModel] _ in viewModel?.toggleFavorite() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

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
                    title: String(localized: "Product unavailable"),
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
            .padding(.horizontal, .medium)

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

        CommerceSurface {

            VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                ProductDetailsSummaryView(product: product)

                ProductOptionsView(product: product, contentInset: self.style.spacing(.medium))
                    .padding(.horizontal, -self.style.spacing(.medium))

                description(product)

            }

        }

    }

    @ViewBuilder
    private func contactActions() -> some View {

        CommerceSurface {

            HStack(spacing: self.style.spacing(.extraSmall)) {

                Text(String(localized: "Interested? Hit Us Up!"))
                    .appFont(with: .BODY_2)
                    .foregroundStyle(.text(.title))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                contactAction(
                    title: String(localized: "Get Directions"),
                    systemImage: "map.fill",
                    isEnabled: self.viewModel.canOpenMaps,
                    action: { self.viewModel.openMaps() }
                )

                contactAction(
                    title: String(localized: "Call Store"),
                    systemImage: "phone.fill",
                    isEnabled: self.viewModel.canCallStore,
                    action: { self.viewModel.callStore() }
                )

            }

        }

    }

    @ViewBuilder
    private func contactAction(title: String,
                               systemImage: String,
                               isEnabled: Bool,
                               action: @escaping () -> Void) -> some View {

        Label {
            Text(title)
        } icon: {

            CircularIconView(
                foregroundColor: .text(.button),
                backgroundColor: .foreground(.primary),
                imageSource: .systemImage(systemImage),
                size: self.style.spacing(.large2)
            )

        }
        .labelStyle(.iconOnly)
        .contentShape(Rectangle())
        .asButton(action: action)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)

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

            LazyHStack(alignment: .top, spacing: self.style.spacing(.small2)) {

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
            spacing: self.style.spacing(.small2)
        )

    }

    @ViewBuilder
    private func retryAction() -> some View {

        if self.viewModel.product == nil && self.viewModel.hasLoadFailed {

            LeafLaunchButton(
                title: String(localized: "Try again"),
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

        let description = product.description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        Text(description.isEmpty ? String(localized: "No description available.") : description)
            .appFont(with: .BODY_2)
            .foregroundStyle(.text(.body))
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
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
