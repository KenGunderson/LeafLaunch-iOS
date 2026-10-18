import SwiftUI

struct StoreShopScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @State private var isRefreshing: Bool = false
    @State private var didRefreshProducts: Bool?
    @StateObject private var viewModel: StoreShopViewModel

    @FocusState private var isSearchFocused: Bool

    init(viewModel: StoreShopViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(
            horizontalPadding: .medium,
            refreshConfiguration: .init(
                isRefreshing: self.$isRefreshing,
                indicatorPlacement: .sticky,
                contentLayout: .pushesContent,
                dismissalDelay: 0.7,
                onRefresh: { [weak viewModel] in

                    self.didRefreshProducts = nil
                    self.didRefreshProducts = await viewModel?.refresh()

                },
                indicator: { context in

                    CatalogRefreshIndicator(
                        context: context,
                        hasFailed: self.didRefreshProducts == false,
                        didRefresh: self.didRefreshProducts == true
                    )

                }
            )
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
            viewModel?.loadData(showHud: true)
        }

    }

    @ViewBuilder
    private func navHeader() -> some View {

        StoreNavHeader(
            configuration: self.viewModel.configuration,
            subtitle: self.viewModel.locationDetails?.location.name ?? String(localized: "Choose a Location"),
            onSelectLocation: { [weak viewModel] in viewModel?.changeLocation() },
            onFavorites: { [weak viewModel] in viewModel?.openFavorites() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            catalogControls()
            productFeed()

        }
        .foregroundStyle(self.style.textColor(.body))
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func catalogControls() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            menuTitle()
            searchAndFilters()

            CatalogCategoryFilters(
                categories: self.viewModel.categories,
                selectedCategoryId: self.viewModel.selectedCategoryId,
                selectedSubcategoryId: self.viewModel.selectedSubcategoryId,
                onCategorySelected: { self.viewModel.selectCategory(id: $0) },
                onSubcategorySelected: { self.viewModel.selectSubcategory(id: $0) }
            )
            .padding(.horizontal, -self.style.spacing(.medium))

        }

    }

    @ViewBuilder
    private func menuTitle() -> some View {

        Text(String(localized: "Menu"))
            .appFont(with: .BILLBOARD_2)
            .foregroundStyle(self.style.textColor(.title))
            .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func searchAndFilters() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            searchField()
            filtersMenu()

        }

    }

    @ViewBuilder
    private func searchField() -> some View {

        HStack(spacing: self.style.spacing(.small2)) {

            ImageSource.systemImage("magnifyingglass")
                .view()
                .aspectRatio(contentMode: .fit)
                .frame(width: self.style.spacing(.medium2), height: self.style.spacing(.medium2))
                .foregroundStyle(self.isSearchFocused ? self.style.foreground(.primary) : self.style.textColor(.body))

            TextField(String(localized: "Search products"), text: self.$viewModel.search)
                .appFont(with: .BODY_2)
                .foregroundStyle(self.style.textColor(.title))
                .focused(self.$isSearchFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .onSubmit { self.viewModel.submitSearch() }

            if !self.viewModel.search.isEmpty {

                ImageSource.systemImage("xmark.circle.fill")
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.style.spacing(.medium2), height: self.style.spacing(.medium2))
                    .foregroundStyle(self.style.textColor(.body))
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    .asButton {

                        self.viewModel.clearSearch()
                        self.isSearchFocused = true

                    }

            }

        }
        .padding(.leading, .medium)
        .padding(.trailing, .small)
        .frame(minHeight: 48)
        .background(self.style.background(.secondary))
        .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.medium2))
                .strokeBorder(self.isSearchFocused ? self.style.foreground(.primary) : self.style.background(.border), lineWidth: 1)
                .allowsHitTesting(false)

        }
        .animation(.bouncy, value: self.isSearchFocused)

    }

    @ViewBuilder
    private func filtersMenu() -> some View {

        Menu {

            categoryPicker()
            subcategoryPicker()

            if self.viewModel.hasActiveFilters {

                Button(String(localized: "Clear filters")) {
                    withAnimation(.bouncy) { self.viewModel.clearFilters() }
                }

            }

        } label: {

            HStack(spacing: self.style.spacing(.small)) {

                ImageSource.systemImage("slider.horizontal.3")
                    .view(shouldResize: false)

                Text(String(localized: "Filters"))

            }
            .appFont(with: .BODY_2)
            .foregroundStyle(self.viewModel.hasActiveFilters ? self.style.palette(.link) : self.style.textColor(.title))
            .padding(.horizontal, .small2)
            .frame(minHeight: 48)
            .background(self.style.background(.secondary))
            .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
            .overlay {

                RoundedRectangle(cornerRadius: self.style.radius(.medium2))
                    .strokeBorder(self.style.background(.border), lineWidth: 1)
                    .allowsHitTesting(false)

            }

        }
        .fixedSize(horizontal: true, vertical: false)

    }

    @ViewBuilder
    private func categoryPicker() -> some View {

        Picker(
            String(localized: "Category"),
            selection: Binding(
                get: { self.viewModel.selectedCategoryId },
                set: { id in
                    withAnimation(.bouncy) { self.viewModel.selectCategory(id: id) }
                }
            )
        ) {

            ForEach(self.viewModel.categories) { category in
                Text(category.name).tag(Optional(category.id))
            }

        }

    }

    @ViewBuilder
    private func subcategoryPicker() -> some View {

        if !self.viewModel.subcategories.isEmpty {

            Picker(
                String(localized: "Subcategory"),
                selection: Binding(
                    get: { self.viewModel.selectedSubcategoryId },
                    set: { id in
                        withAnimation(.bouncy) { self.viewModel.selectSubcategory(id: id) }
                    }
                )
            ) {

                ForEach(self.viewModel.subcategories) { subcategory in
                    Text(subcategory.name).tag(Optional(subcategory.id))
                }

            }

        }

    }

    @ViewBuilder
    private func feedHeader() -> some View {

        ViewThatFits(in: .horizontal) {

            HStack(alignment: .center, spacing: self.style.spacing(.small)) {

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

    @ViewBuilder
    private func feedTitle() -> some View {

        Text(self.viewModel.categories.first { $0.id == self.viewModel.selectedCategoryId }?.name ?? String(localized: "Menu"))
            .appFont(with: .TITLE_6)
            .foregroundStyle(self.style.textColor(.title))
            .contentTransition(.numericText())
            .animation(.bouncy, value: self.viewModel.selectedCategoryId)

    }

    @ViewBuilder
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
                    .contentTransition(.numericText())

                ImageSource.systemImage("chevron.down")
                    .view(shouldResize: false)

            }
            .appFont(with: .TITLE_1)
            .foregroundStyle(self.style.textColor(.title))
            .padding(.horizontal, .small2)
            .frame(minHeight: 44)
            .background(self.style.background(.secondary))
            .clipShape(Capsule())
            .overlay {

                Capsule()
                    .strokeBorder(self.style.background(.border), lineWidth: 1)
                    .allowsHitTesting(false)

            }
            .animation(.bouncy, value: self.viewModel.sort)

        }

    }

    @ViewBuilder
    private func productFeed() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            feedHeader()

            loadingProducts()

            feedState()

            ProductGridView(
                products: self.viewModel.products,
                favoriteProductIds: self.viewModel.favoriteProductIds,
                onOpen: { self.viewModel.openProduct(id: $0) },
                onFavorite: { self.viewModel.toggleFavorite(id: $0) }
            )

            feedActions()

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

                if self.viewModel.hasActiveFilters {

                    Text(String(localized: "Clear filters"))
                        .appFont(with: .TITLE_2)
                        .foregroundStyle(self.style.palette(.link))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .asButton {
                            self.viewModel.clearFilters()
                        }

                }

            }

        }

    }

    @ViewBuilder
    private func loadingProducts() -> some View {

        if self.viewModel.isLoading && self.viewModel.products.isEmpty {

            ProgressView(String(localized: "Loading products"))
                .tint(self.style.accent)
                .appFont(with: .BODY_2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, .large)

        }

    }

    @ViewBuilder
    private func feedActions() -> some View {

        if self.viewModel.hasMoreProducts {

            LeafLaunchButton(title: self.viewModel.isLoading ? String(localized: "Loading products") : String(localized: "Load More Products")) {
                self.viewModel.loadMore()
            }
            .disabled(self.viewModel.isLoading)

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
