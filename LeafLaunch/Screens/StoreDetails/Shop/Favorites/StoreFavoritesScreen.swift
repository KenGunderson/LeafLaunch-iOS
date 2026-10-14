import SwiftUI

struct StoreFavoritesScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: StoreFavoritesViewModel

    init(viewModel: StoreFavoritesViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {
            NavHeader(title: String(localized: "Favorites"))
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

    private func content() -> some View {

        LazyVStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            if self.viewModel.hasCompletedInitialLoad && self.viewModel.products.isEmpty && !self.viewModel.isLoading {
                Text(String(localized: "No favorite products are available at this location."))
            }

            ForEach(self.viewModel.products, id: \.id) { product in

                ProductWireframeRow(
                    product: product,
                    isFavorite: true,
                    onOpen: { self.viewModel.openProduct(id: product.id) },
                    onFavorite: { self.viewModel.removeFavorite(id: product.id) }
                )

            }

        }
        .foregroundStyle(.text(.body))
        .tabFlowContentSpacing()

    }

}

#Preview {

    StoreFavoritesScreen(
        viewModel: mockResolve(StoreFavoritesViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockServices()

}
