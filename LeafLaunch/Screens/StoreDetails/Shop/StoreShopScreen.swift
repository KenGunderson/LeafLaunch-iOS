import SwiftUI

struct StoreShopScreen: GPView {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: StoreShopViewModel

    @FocusState private var isSearchFocused: Bool

    init(viewModel: StoreShopViewModel) {
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
        NavHeader(title: String(localized: "Shop"), subtitle: String(localized: "Find your next favorite"))
    }

    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            searchField()

            CatalogCategoryFilters(
                categories: self.viewModel.categories,
                selectedCategoryId: self.viewModel.selectedCategoryId,
                selectedSubcategoryId: self.viewModel.selectedSubcategoryId,
                onCategorySelected: { self.viewModel.selectCategory(id: $0) },
                onSubcategorySelected: { self.viewModel.selectSubcategory(id: $0) }
            )

            productFeed()

        }
        .foregroundStyle(self.style.textColor(.body))
        .tabFlowContentSpacing()

    }

    private func searchField() -> some View {

        HStack(spacing: self.style.spacing(.small2)) {

            ImageSource.systemImage("magnifyingglass")
                .view()
                .aspectRatio(contentMode: .fit)
                .frame(width: self.style.spacing(.medium2), height: self.style.spacing(.medium2))
                .foregroundStyle(self.style.foreground(.secondary))
                .accessibilityHidden(true)

            TextField(String(localized: "Search products"), text: self.$viewModel.search)
                .appFont(with: .BODY_2)
                .foregroundStyle(self.style.textColor(.title))
                .focused(self.$isSearchFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .onSubmit { self.viewModel.loadData(showHud: false) }
                .accessibilityLabel(String(localized: "Search products"))

            if !self.viewModel.search.isEmpty {

                ImageSource.systemImage("xmark.circle.fill")
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.style.spacing(.medium2), height: self.style.spacing(.medium2))
                    .foregroundStyle(self.style.textColor(.body))
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    .asButton(scale: self.reduceMotion ? 1 : nil) {

                        self.viewModel.clearSearch()
                        self.isSearchFocused = true

                    }
                    .accessibilityLabel(String(localized: "Clear search"))

            }

        }
        .padding(.leading, .medium)
        .padding(.trailing, .small)
        .padding(.vertical, .extraSmall)
        .frame(minHeight: 52)
        .background(self.style.background(.secondary))
        .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.medium2))
                .strokeBorder(self.isSearchFocused ? self.style.foreground(.primary) : self.style.background(.border), lineWidth: 1)
                .allowsHitTesting(false)

        }
        .animation(self.reduceMotion ? nil : .bouncy, value: self.isSearchFocused)

    }

    private func feedHeader() -> some View {

        ViewThatFits(in: .horizontal) {

            HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small)) {

                feedTitle()
                Spacer(minLength: self.style.spacing(.small))
                sortMenu()

            }

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                feedTitle()
                sortMenu()

            }

        }

    }

    private func feedTitle() -> some View {

        Text(self.viewModel.categories.first { $0.id == self.viewModel.selectedCategoryId }?.name ?? String(localized: "All products"))
            .appFont(with: .TITLE_6)
            .foregroundStyle(self.style.textColor(.title))
            .accessibilityAddTraits(.isHeader)

    }

    private func sortMenu() -> some View {

        Menu {

            Picker(String(localized: "Sort products"), selection: self.$viewModel.sort) {

                ForEach(ProductSort.allCases) { sort in
                    Text(sort.title).tag(sort)
                }

            }

        } label: {

            HStack(spacing: self.style.spacing(.small)) {

                ImageSource.systemImage("arrow.up.arrow.down")
                    .view(shouldResize: false)

                Text(self.viewModel.sort.title)

                ImageSource.systemImage("chevron.down")
                    .view(shouldResize: false)

            }
            .appFont(with: .TITLE_1)
            .foregroundStyle(self.style.textColor(.title))
            .padding(.horizontal, .small2)
            .frame(minHeight: 44)
            .background(self.style.background(.secondary))
            .clipShape(Capsule())

        }
        .accessibilityLabel(String(localized: "Sort products"))
        .accessibilityValue(self.viewModel.sort.title)

    }

    private func productFeed() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            feedHeader()

            if self.viewModel.isLoading && self.viewModel.products.isEmpty {

                ProgressView(String(localized: "Loading products"))
                    .tint(self.style.accent)
                    .appFont(with: .BODY_2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .large)

            }

            feedState()

            ProductGridView(
                products: self.viewModel.products,
                imageURLs: self.viewModel.imageURLs,
                loadingImageProductIds: self.viewModel.loadingImageProductIds,
                favoriteProductIds: self.viewModel.favoriteProductIds,
                onOpen: { self.viewModel.openProduct(id: $0) },
                onFavorite: { self.viewModel.toggleFavorite(id: $0) }
            )

            if self.viewModel.hasMoreProducts {

                LeafLaunchButton(title: self.viewModel.isLoading ? String(localized: "Loading products") : String(localized: "Load More Products")) {
                    self.viewModel.loadMore()
                }
                .disabled(self.viewModel.isLoading)

            }

            if !self.viewModel.products.isEmpty && !self.viewModel.isLoading {

                Button(String(localized: "Refresh Products")) {
                    self.viewModel.loadData(showHud: false)
                }
                .appFont(with: .TITLE_2)
                .tint(self.style.palette(.link))
                .frame(maxWidth: .infinity, minHeight: 44)

            }

        }

    }

    @ViewBuilder
    private func feedState() -> some View {

        if self.viewModel.hasLoadFailed && self.viewModel.products.isEmpty && !self.viewModel.isLoading {

            VStack(spacing: self.style.spacing(.small)) {

                CommerceEmptyState(
                    systemImage: "wifi.exclamationmark",
                    title: String(localized: "Products couldn't load"),
                    message: String(localized: "Check your connection and try again.")
                )

                LeafLaunchButton(title: String(localized: "Try again")) {
                    self.viewModel.loadData(showHud: false)
                }

            }

        } else if self.viewModel.hasCompletedInitialLoad && self.viewModel.products.isEmpty && !self.viewModel.isLoading {

            VStack(spacing: self.style.spacing(.small)) {

                CommerceEmptyState(
                    systemImage: "magnifyingglass",
                    title: String(localized: "No products found"),
                    message: String(localized: "Try another search or category to see more products.")
                )

                if !self.viewModel.search.isEmpty || self.viewModel.selectedCategoryId != nil {

                    Button(String(localized: "Clear filters")) {
                        self.viewModel.clearFilters()
                    }
                    .appFont(with: .TITLE_2)
                    .tint(self.style.palette(.link))
                    .frame(maxWidth: .infinity, minHeight: 44)

                }

            }

        }

    }

}

#Preview {

    StoreShopScreen(
        viewModel: mockResolve(StoreShopViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
