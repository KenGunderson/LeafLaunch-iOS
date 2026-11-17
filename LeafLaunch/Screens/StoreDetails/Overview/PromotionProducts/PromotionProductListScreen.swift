import SwiftUI

struct PromotionProductListScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: PromotionProductListViewModel

    init(viewModel: PromotionProductListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        LLAppHeaderScrollView {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

    }

    @ContentBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Promotion Products"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

            CommerceSectionHeader(title: self.viewModel.title)
            products()

        }
        .tabFlowContentSpacing()

    }

    @ContentBuilder
    private func products() -> some View {

        if self.viewModel.products.isEmpty {

            CommerceEmptyState(
                systemImage: "bag",
                title: String(localized: "No Linked Products"),
                message: String(localized: "This promotion has no products to browse.")
            )

        } else {

            LazyVStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

                ForEach(self.viewModel.products) { product in
                    productRow(product)
                }

            }

        }

    }

    @ContentBuilder
    private func productRow(_ product: PromotionLinkedProduct) -> some View {

        CommerceSurface {

            HStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

                productLabel(product)
                    .frame(maxWidth: .infinity, alignment: .leading)

                RNImageSource.systemImage(product.locationProductListingId == nil ? "info.circle" : "chevron.right")
                    .view(shouldResize: false)
                    .runeForeground(.secondary)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())

        }
        .runeAsButton { [weak viewModel] in viewModel?.openProduct(product) }

    }

    @ContentBuilder
    private func productLabel(_ product: PromotionLinkedProduct) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            Text(product.displayName)
                .runeFont(with: .TITLE_3)
                .runeTextColor(.title)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            if product.locationProductListingId == nil {

                Text(String(localized: "Unavailable At This Location"))
                    .runeFont(with: .BODY_2)
                    .runeTextColor(.body)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

            }

        }

    }

}

#Preview {

    if let promotion = MockCustomerModels.promotions.first(where: { $0.linkedProducts.count > 1 }) {

        PromotionProductListScreen(
            viewModel: mockResolve(PromotionProductListViewModel.self)
                .setup(
                    locationId: MockCustomerModels.primaryLocationId,
                    promotionId: promotion.id,
                    title: promotion.title,
                    products: promotion.linkedProducts
                )
        )
        .withMockPreviews()

    }

}
