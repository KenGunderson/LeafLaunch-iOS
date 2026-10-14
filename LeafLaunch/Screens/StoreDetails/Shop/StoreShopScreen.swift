import SwiftUI

struct StoreShopScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: StoreShopViewModel

    @FocusState private var isSearchFocused: Bool

    init(viewModel: StoreShopViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {
            NavHeader(title: String(localized: "Shop"))
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

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            headerControls()
            categoryFilters()
            productFeed()

        }
        .foregroundStyle(.text(.body))

    }

    private func headerControls() -> some View {

        GroupBox(String(localized: "Search and Sort")) {

            VStack(spacing: self.style.spacing(.small)) {

                TextField(String(localized: "Search products"), text: self.$viewModel.search)
                    .textFieldStyle(.roundedBorder)
                    .focused(self.$isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit { self.viewModel.loadData(showHud: true) }

                if !self.viewModel.search.isEmpty {

                    Button(String(localized: "Clear search")) {

                        self.viewModel.clearSearch()
                        self.isSearchFocused = true

                    }

                }

                LeafLaunchButton(
                    title: String(localized: "Search"),
                    icon: .systemImage("magnifyingglass")
                ) {
                    self.viewModel.loadData(showHud: true)
                }

                Picker(String(localized: "Sort"), selection: self.$viewModel.sort) {

                    ForEach(ProductSort.allCases) { sort in
                        Text(sort.title).tag(sort)
                    }

                }
                .pickerStyle(.menu)

            }

        }

    }

    private func categoryFilters() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            ScrollView(.horizontal) {

                HStack(spacing: self.style.spacing(.small)) {

                    Button(self.viewModel.selectedCategoryId == nil ? "✓ All" : "All") {
                        self.viewModel.selectCategory(id: nil)
                    }

                    ForEach(self.viewModel.categories, id: \.id) { category in

                        Button(self.viewModel.selectedCategoryId == category.id ? "✓ \(category.name)" : category.name) {
                            self.viewModel.selectCategory(id: category.id)
                        }
                        .accessibilityValue(self.viewModel.selectedCategoryId == category.id ? String(localized: "Selected") : "")

                    }

                }
                .buttonStyle(.bordered)

            }

            if self.viewModel.selectedCategoryId != nil {

                ScrollView(.horizontal) {

                    HStack(spacing: self.style.spacing(.small)) {

                        Button(self.viewModel.selectedSubcategoryId == nil ? "✓ All subcategories" : "All subcategories") {
                            self.viewModel.selectSubcategory(id: nil)
                        }

                        ForEach(self.viewModel.subcategories, id: \.id) { subcategory in

                            Button(self.viewModel.selectedSubcategoryId == subcategory.id ? "✓ \(subcategory.name)" : subcategory.name) {
                                self.viewModel.selectSubcategory(id: subcategory.id)
                            }
                            .accessibilityValue(self.viewModel.selectedSubcategoryId == subcategory.id ? String(localized: "Selected") : "")

                        }

                    }
                    .buttonStyle(.bordered)

                }
                .id(self.viewModel.selectedCategoryId)

            }

        }

    }

    private func productFeed() -> some View {

        LazyVStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            if self.viewModel.hasCompletedInitialLoad && self.viewModel.products.isEmpty && !self.viewModel.isLoading {
                Text(String(localized: "No products match these filters."))
            }

            ForEach(self.viewModel.products, id: \.id) { product in

                ProductWireframeRow(
                    product: product,
                    isFavorite: self.viewModel.favoriteProductIds.contains(product.id),
                    onOpen: { self.viewModel.openProduct(id: product.id) },
                    onFavorite: { self.viewModel.toggleFavorite(id: product.id) }
                )

            }

            if self.viewModel.hasMoreProducts {

                LeafLaunchButton(title: String(localized: "Load More Products")) {
                    self.viewModel.loadMore()
                }
                .disabled(self.viewModel.isLoading)

            }

            if !self.viewModel.isLoading {

                Button(String(localized: "Refresh Products")) {
                    self.viewModel.loadData(showHud: true)
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
    .withMockServices()

}
