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

    @ViewBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Promotion Products"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            CommerceSectionHeader(title: self.viewModel.title)
            products()

        }
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func products() -> some View {

        if self.viewModel.products.isEmpty {

            CommerceEmptyState(
                systemImage: "bag",
                title: String(localized: "No Linked Products"),
                message: String(localized: "This promotion has no products to browse.")
            )

        } else {

            LazyVStack(spacing: self.style.spacing(.small2)) {

                ForEach(self.viewModel.products) { product in
                    productRow(product)
                }

            }

        }

    }

    @ViewBuilder
    private func productRow(_ product: PromotionLinkedProduct) -> some View {

        CommerceSurface {

            HStack(spacing: self.style.spacing(.small2)) {

                productLabel(product)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ImageSource.systemImage(product.locationProductListingId == nil ? "info.circle" : "chevron.right")
                    .view(shouldResize: false)
                    .foregroundStyle(self.style.foreground(.secondary))

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())

        }
        .asButton { [weak viewModel] in viewModel?.openProduct(product) }

    }

    @ViewBuilder
    private func productLabel(_ product: PromotionLinkedProduct) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(product.displayName)
                .appFont(with: .TITLE_3)
                .foregroundStyle(.text(.title))
                .fixedSize(horizontal: false, vertical: true)

            if product.locationProductListingId == nil {

                Text(String(localized: "Unavailable at This Location"))
                    .appFont(with: .BODY_2)
                    .foregroundStyle(.text(.body))
                    .fixedSize(horizontal: false, vertical: true)

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
