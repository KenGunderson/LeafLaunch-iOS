import SwiftUI

struct FavoriteProductsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: FavoriteProductsViewModel

    init(viewModel: FavoriteProductsViewModel) {
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
        .task { [weak viewModel] in
            viewModel?.loadData(showHud: true)
        }

    }

    @ViewBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Favorite Products"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            loadingContent()
            emptyContent()
            collection()

        }
        .foregroundStyle(self.style.textColor(.body))
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func loadingContent() -> some View {

        if self.viewModel.isLoading && self.viewModel.products.isEmpty {

            ProgressView(String(localized: "Loading favorites"))
                .tint(self.style.accent)
                .appFont(with: .BODY_2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, .large)

        }

    }

    @ViewBuilder
    private func collection() -> some View {

        if !self.viewModel.products.isEmpty {

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                CommerceSectionHeader(
                    title: String(localized: "Your collection"),
                    subtitle: String(localized: "Available at this location")
                )

                ProductGridView(
                    products: self.viewModel.products,
                    favoriteProductIds: Set(self.viewModel.products.map(\.id)),
                    onOpen: { self.viewModel.openProduct(id: $0) },
                    onFavorite: { self.viewModel.removeFavorite(id: $0) }
                )
                .animation(.bouncy, value: self.viewModel.products.map(\.id))

            }

        }

    }

    @ViewBuilder
    private func emptyContent() -> some View {

        if self.viewModel.hasLoadFailed && self.viewModel.products.isEmpty && !self.viewModel.isLoading {

            VStack(spacing: self.style.spacing(.small)) {

                CommerceEmptyState(
                    systemImage: "wifi.exclamationmark",
                    title: String(localized: "Favorites couldn't load"),
                    message: String(localized: "Check your connection and try again.")
                )

                LeafLaunchButton(title: String(localized: "Try again")) {
                    self.viewModel.loadData(showHud: false)
                }

            }

        } else if self.viewModel.hasCompletedInitialLoad && self.viewModel.products.isEmpty && !self.viewModel.isLoading {

            VStack(spacing: self.style.spacing(.small)) {

                CommerceEmptyState(
                    systemImage: "heart",
                    title: String(localized: "Make room for favorites"),
                    message: String(localized: "Tap the heart on a product to save it here. Saved products appear when available at this location.")
                )

                LeafLaunchButton(title: String(localized: "Browse products"), icon: .systemImage("arrow.right")) {
                    self.viewModel.browseProducts()
                }

            }

        }

    }

}

#Preview {

    FavoriteProductsScreen(
        viewModel: mockResolve(FavoriteProductsViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
