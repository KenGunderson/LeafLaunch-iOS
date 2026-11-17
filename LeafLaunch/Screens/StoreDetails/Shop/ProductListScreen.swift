import SwiftUI

struct ProductListScreen: GPView {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(NavigationService.self) private var navigationService

    @State private var isRefreshing: Bool = false
    @State private var didRefreshProducts: Bool?
    @StateObject private var viewModel: ProductListViewModel

    @FocusState private var isSearchFocused: Bool

    private var isLoadingProducts: Bool {
        let hasNoProducts = self.viewModel.products.isEmpty && !self.viewModel.hasCompletedInitialLoad
        return self.viewModel.isLoading && hasNoProducts
    }

    private var selectedSectionTitle: String {

        self.viewModel.subcategories.first { $0.id == self.viewModel.selectedSubcategoryId }?.name
            ?? self.viewModel.categories.first { $0.id == self.viewModel.selectedCategoryId }?.name
            ?? String(localized: "Products")

    }

    private var resultTransitionId: [String] {

        [
            self.viewModel.selectedCategoryId ?? "",
            self.viewModel.selectedSubcategoryId ?? "",
            self.viewModel.sort.id,
            self.isLoadingProducts ? "loading" : "content"
        ]

    }

    init(viewModel: ProductListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        RNHeaderScrollView(
            horizontalPadding: .medium,
            refreshConfiguration: .init(
                isRefreshing: self.$isRefreshing,
                threshold: 80,
                indicatorPlacement: .sticky,
                contentLayout: .pushesContent,
                dismissalDelay: 0.45,
                onRefresh: { [weak viewModel] in

                    self.didRefreshProducts = nil
                    let didRefresh = await viewModel?.refresh()
                    guard !Task.isCancelled else { return }

                    self.didRefreshProducts = didRefresh

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
            viewModel?.loadData(showHud: self.viewModel.isFirstLoad)
        }

    }

    @ContentBuilder
    private func navHeader() -> some View {

        StoreNavHeader(
            configuration: self.viewModel.configuration,
            subtitle: self.viewModel.locationDetails?.location.name ?? String(localized: "Choose A Location"),
            onSelectLocation: { [weak viewModel] in viewModel?.changeLocation() },
            onFavorites: { [weak viewModel] in viewModel?.openFavorites() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            catalogControls()
            productFeed()

        }
        .runeTextColor(.body)
        .tabFlowContentSpacing()

    }

    @ContentBuilder
    private func catalogControls() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

            menuTitle()
            searchAndFilters()

            CatalogCategoryFilters(
                categories: self.viewModel.categories,
                selectedCategoryId: self.viewModel.selectedCategoryId,
                selectedSubcategoryId: self.viewModel.selectedSubcategoryId,
                onCategorySelected: { self.viewModel.selectCategory(id: $0) },
                onSubcategorySelected: { self.viewModel.selectSubcategory(id: $0) }
            )
            .runePadding(.horizontal, .custom(-self.style.spacing(LLSpacing.listRow)))

        }

    }

    @ContentBuilder
    private func menuTitle() -> some View {

        Text(String(localized: "Menu"))
            .runeFont(with: LeafLaunchThemeTokens.headingFont)
            .runeTextColor(.title)
            .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func searchAndFilters() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            searchField()
            filtersMenu()

        }

    }

    @ContentBuilder
    private func searchField() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            RNImageSource.systemImage("magnifyingglass")
                .view()
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: self.style.spacing(.medium2),
                    height: self.style.spacing(.medium2)
                )
                .foregroundStyle(self.isSearchFocused ? RNColorSource.foreground(.primary) : RNColorSource.text(.body))

            TextField(
                String(localized: "Search The Menu"),
                text: self.$viewModel.search
            )
                .runeFont(with: .BODY_2)
                .runeTextColor(.title)
                .focused(self.$isSearchFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .onSubmit { self.viewModel.submitSearch() }

            if !self.viewModel.search.isEmpty {

                RNImageSource.systemImage("xmark.circle.fill")
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: self.style.spacing(.medium2),
                        height: self.style.spacing(.medium2)
                    )
                    .runeTextColor(.body)
                    .frame(
                        minWidth: 44,
                        minHeight: 44
                    )
                    .contentShape(Rectangle())
                    .runeAsButton {

                        self.viewModel.clearSearch()
                        self.isSearchFocused = true

                    }

            }

        }
        .runePadding(.leading, LLSpacing.pageInset)
        .runePadding(.trailing, LLSpacing.groupedContent)
        .frame(minHeight: 48)
        .runeBackground(.secondary)
        .runeCornerRadius(.medium2)
        .overlay {

            RoundedRectangle(cornerRadius: self.style.radius(.medium2))
                .strokeBorder(
                    self.isSearchFocused ? RNColorSource.foreground(.primary) : RNColorSource.background(.border),
                    lineWidth: 1
                )
                .allowsHitTesting(false)

        }
        .animation(
            .bouncy,
            value: self.isSearchFocused
        )

    }

    @ContentBuilder
    private func filtersMenu() -> some View {

        Menu {

            categoryPicker()
            subcategoryPicker()

            if self.viewModel.hasActiveFilters {

                Button(String(localized: "Clear Filters")) {
                    withAnimation(self.reduceMotion ? nil : .bouncy) { self.viewModel.clearFilters() }
                }

            }

        } label: {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                RNImageSource.systemImage("slider.horizontal.3")
                    .view(shouldResize: false)

                Text(String(localized: "Filters"))

            }
            .runeFont(with: .BODY_2)
            .foregroundStyle(self.viewModel.hasActiveFilters ? RNColorSource.palette(.link) : RNColorSource.text(.title))
            .runePadding(.horizontal, LLSpacing.cardContent)
            .frame(minHeight: 48)
            .runeBackground(.secondary)
            .runeCornerRadius(.medium2)
            .overlay {

                RoundedRectangle(cornerRadius: self.style.radius(.medium2))
                    .strokeBorder(
                        RNColorSource.background(.border),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)

            }

        }
        .fixedSize(
            horizontal: true,
            vertical: false
        )

    }

    @ContentBuilder
    private func categoryPicker() -> some View {

        Picker(
            String(localized: "Category"),
            selection: Binding(
                get: { self.viewModel.selectedCategoryId },
                set: { id in
                    withAnimation(self.reduceMotion ? nil : .bouncy) { self.viewModel.selectCategory(id: id) }
                }
            )
        ) {

            ForEach(self.viewModel.categories) { category in
                Text(category.name).tag(Optional(category.id))
            }

        }

    }

    @ContentBuilder
    private func subcategoryPicker() -> some View {

        if self.viewModel.subcategories.count > 1 {

            Picker(
                String(localized: "Subcategory"),
                selection: Binding(
                    get: { self.viewModel.selectedSubcategoryId },
                    set: { id in
                        withAnimation(self.reduceMotion ? nil : .bouncy) { self.viewModel.selectSubcategory(id: id) }
                    }
                )
            ) {

                ForEach(self.viewModel.subcategories) { subcategory in
                    Text(subcategory.name).tag(Optional(subcategory.id))
                }

            }

        }

    }

    @ContentBuilder
    private func feedHeader() -> some View {

        ViewThatFits(in: .horizontal) {

            HStack(
                alignment: .center,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                feedTitle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                sortMenu()
                    .layoutPriority(1)

            }

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                feedTitle()
                sortMenu()

            }

        }

    }

    @ContentBuilder
    private func feedTitle() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.none)
        ) {

            Text(self.selectedSectionTitle)
                .runeFont(with: .HEADER_2)
                .runeTextColor(.title)
                .minimumScaleFactor(0.75)
                .contentTransition(.numericText())
                .animation(
                    self.reduceMotion ? nil : .bouncy,
                    value: self.selectedSectionTitle
                )

            if !self.viewModel.products.isEmpty {

                Text(self.viewModel.hasMoreProducts
                     ? String(localized: "\(self.viewModel.products.count)+ Products")
                     : String(localized: "\(self.viewModel.products.count) Products"))
                .monospacedDigit()
                .runeFont(with: .NOTE_2)
                .runeTextColor(.body)
                .contentTransition(.numericText())

            }

        }

    }

    @ContentBuilder
    private func sortMenu() -> some View {

        Menu {

            Picker(
                String(localized: "Sort Products"),
                selection: Binding(
                    get: { self.viewModel.sort },
                    set: { sort in
                        withAnimation(self.reduceMotion ? nil : .bouncy) { self.viewModel.sort = sort }
                    }
                )
            ) {

                ForEach(ProductSort.allCases) { sort in
                    Text(sort.title).tag(sort)
                }

            }

        } label: {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                Text(self.viewModel.sort.compactTitle)
                    .contentTransition(.numericText())
                    .accessibilityLabel(self.viewModel.sort.title)

                RNImageSource.systemImage("chevron.down")
                    .view(shouldResize: false)

            }
            .runeFont(with: .TITLE_1)
            .runeTextColor(.title)
            .runePadding(.horizontal, LLSpacing.cardContent)
            .frame(minHeight: 44)
            .runeBackground(.secondary)
            .clipShape(Capsule())
            .overlay {

                Capsule()
                    .strokeBorder(
                        RNColorSource.background(.border),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)

            }
            .animation(
                self.reduceMotion ? nil : .bouncy,
                value: self.viewModel.sort
            )

        }
        .fixedSize(
            horizontal: true,
            vertical: false
        )

    }

    @ContentBuilder
    private func productFeed() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

            feedHeader()
            activeFilters()

            productResults()

        }

    }

    @ContentBuilder
    private func productResults() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

            loadingProducts()

            feedState()

            ProductGridView(
                products: self.viewModel.products,
                favoriteProductIds: self.viewModel.favoriteProductIds,
                onOpen: { self.viewModel.openProduct(id: $0) },
                onFavorite: { self.viewModel.toggleFavorite(id: $0) }
            )
            .llBlurReplace(
                value: self.resultTransitionId,
                transition: AnyTransition(.blurReplace).combined(with: .scale(scale: 0.75)),
                animation: self.reduceMotion ? nil : .bouncy
            )

            feedActions()

        }

    }

    @ContentBuilder
    private func activeFilters() -> some View {

        if self.viewModel.hasActiveFilters {

            HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                Text(String(localized: "Filtered Results"))
                    .runeFont(with: .NOTE_1)
                    .runeTextColor(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(String(localized: "Reset"))
                    .runeFont(with: .TITLE_2)
                    .foregroundStyle(RNColorSource.palette(.link))
                    .frame(
                        minWidth: 44,
                        minHeight: 44
                    )
                    .runeAsButton { self.viewModel.clearFilters() }

            }

        }

    }

    @ContentBuilder
    private func feedState() -> some View {

        let hasNoProducts = self.viewModel.products.isEmpty
        let hasInitialFailure = self.viewModel.hasLoadFailed && !self.viewModel.hasCompletedInitialLoad

        if hasInitialFailure && hasNoProducts && !self.viewModel.isLoading {

            VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                CommerceEmptyState(
                    systemImage: "wifi.exclamationmark",
                    title: String(localized: "Products Couldn't Load"),
                    message: String(localized: "Check your connection and try again.")
                )

                LeafLaunchButton(title: String(localized: "Try Again")) {
                    self.viewModel.loadData(showHud: false)
                }

            }

        } else if self.viewModel.hasCompletedInitialLoad && self.viewModel.products.isEmpty {

            VStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                CommerceEmptyState(
                    systemImage: "magnifyingglass",
                    title: String(localized: "No Products Found"),
                    message: String(localized: "Try another search or category to see more products.")
                )

                if self.viewModel.hasActiveFilters {

                    Text(String(localized: "Clear Filters"))
                        .runeFont(with: .TITLE_2)
                        .foregroundStyle(RNColorSource.palette(.link))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .runeAsButton {
                            self.viewModel.clearFilters()
                        }

                }

            }

        }

    }

    @ContentBuilder
    private func loadingProducts() -> some View {

        if self.isLoadingProducts {

            ProgressView(String(localized: "Loading Products"))
                .runeTint(.primary)
                .runeFont(with: .BODY_2)
                .frame(maxWidth: .infinity)
                .runePadding(.vertical, LLSpacing.content)

        }

    }

    @ContentBuilder
    private func feedActions() -> some View {

        if self.viewModel.hasMoreProducts {

            LeafLaunchButton(title: self.viewModel.isLoading ? String(localized: "Loading Products") : String(localized: "Load More Products")) {
                self.viewModel.loadMore()
            }
            .disabled(self.viewModel.isLoading)

        }

    }

}

#Preview {

    ProductListScreen(
        viewModel: mockResolve(ProductListViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
