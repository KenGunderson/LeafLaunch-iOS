import SwiftUI

struct FavoriteProductListScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: FavoriteProductListViewModel

    init(viewModel: FavoriteProductListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        LLAppHeaderScrollView(onRefresh: { [weak viewModel] in await viewModel?.refreshData() }) {
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
            title: String(localized: "Favorite Products"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            loadingContent()
            emptyContent()
            collection()

        }
        .runeTextColor(.body)
        .tabFlowContentSpacing()

    }

    @ContentBuilder
    private func loadingContent() -> some View {

        let hasUnresolvedProducts = self.viewModel.products.isEmpty && !self.viewModel.hasCompletedInitialLoad

        if self.viewModel.isLoading && hasUnresolvedProducts {

            ProgressView(String(localized: "Loading Favorites"))
                .runeTint(.primary)
                .runeFont(with: .BODY_2)
                .frame(maxWidth: .infinity)
                .runePadding(.vertical, LLSpacing.content)

        }

    }

    @ContentBuilder
    private func collection() -> some View {

        if !self.viewModel.products.isEmpty {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.cardContent)
            ) {

                CommerceSectionHeader(
                    title: String(localized: "Your Collection"),
                    subtitle: String(localized: "Available At This Location")
                )

                ProductGridView(
                    products: self.viewModel.products,
                    favoriteProductIds: Set(self.viewModel.products.map(\.id)),
                    onOpen: { self.viewModel.openProduct(id: $0) },
                    onFavorite: { self.viewModel.removeFavorite(id: $0) }
                )
                .animation(
                    .bouncy,
                    value: self.viewModel.products.map(\.id)
                )

            }

        }

    }

    @ContentBuilder
    private func emptyContent() -> some View {

        let hasNoProducts = self.viewModel.products.isEmpty
        let hasInitialFailure = self.viewModel.hasLoadFailed && !self.viewModel.hasCompletedInitialLoad

        if hasInitialFailure && hasNoProducts && !self.viewModel.isLoading {

            VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                CommerceEmptyState(
                    systemImage: "wifi.exclamationmark",
                    title: String(localized: "Favorites Couldn't Load"),
                    message: String(localized: "Check your connection and try again.")
                )

                LeafLaunchButton(title: String(localized: "Try Again")) {
                    self.viewModel.loadData(showHud: false)
                }

            }

        } else if self.viewModel.hasCompletedInitialLoad && self.viewModel.products.isEmpty {

            VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                CommerceEmptyState(
                    systemImage: "heart",
                    title: String(localized: "Make Room For Favorites"),
                    message: String(localized: "Tap the heart on a product to save it here. Saved products appear when available at this location.")
                )

                LeafLaunchButton(
                    title: String(localized: "Browse Products"),
                    icon: .systemImage("arrow.right")
                ) {
                    self.viewModel.browseProducts()
                }

            }

        }

    }

}

#Preview {

    FavoriteProductListScreen(
        viewModel: mockResolve(FavoriteProductListViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
