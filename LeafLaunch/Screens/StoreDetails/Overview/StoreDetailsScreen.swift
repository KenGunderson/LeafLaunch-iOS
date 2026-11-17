import SwiftUI

struct StoreDetailsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(NavigationService.self) private var navigationService
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService

    @StateObject private var viewModel: StoreDetailsViewModel

    init(viewModel: StoreDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        ScrollViewReader { proxy in

            LLAppHeaderScrollView(
                horizontalPadding: .none,
                onRefresh: { [weak viewModel = viewModel] in await viewModel?.refreshData() }
            ) {
                navHeader()
            } scrollViewContent: {
                content(scrollProxy: proxy)
            }

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
            onSelectLocation: { [weak viewModel] in viewModel?.changeLocation() }
        )

    }

    @ContentBuilder
    private func content(scrollProxy: ScrollViewProxy) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            visitSummary(scrollProxy: scrollProxy)
                .runePadding(.bottom, LLSpacing.listRow)

            storefrontSections()

            storeInfo()
                .id("store-info")

        }
        .runeTextColor(.body)

    }

    @ContentBuilder
    private func visitSummary(scrollProxy: ScrollViewProxy) -> some View {

        if let details = self.viewModel.locationDetails {

            StoreVisitSummaryView(details: details) {

                withAnimation(self.reduceMotion ? nil : .easeInOut(duration: 0.3)) {

                    scrollProxy.scrollTo(
                        "store-info",
                        anchor: .top
                    )

                }

            }
            .runePadding(.horizontal, LLSpacing.pageInset)

        }

    }

    @ContentBuilder
    private func storefrontSections() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            promotions()
            featuredProducts()
            events()
            reloadAction()

        }
        .animation(
            .bouncy,
            value: self.viewModel.promotions.isEmpty
        )
        .animation(
            .bouncy,
            value: self.viewModel.events.isEmpty
        )

    }

    @ContentBuilder
    private func sectionHeader(_ title: String) -> some View {

        CommerceSectionHeader(title: title)
            .runePadding(.horizontal, LLSpacing.pageInset)

    }

    @ContentBuilder
    private func storeInfo() -> some View {

        if self.viewModel.store != nil || self.viewModel.locationDetails != nil {

            StoreInfoView(
                store: self.viewModel.store,
                details: self.viewModel.locationDetails
            )

        }

    }

    @ContentBuilder
    private func reloadAction() -> some View {

        if !self.viewModel.hasCompletedInitialLoad && !self.viewModel.isLoading {

            LeafLaunchButton(
                title: String(localized: "Reload Store"),
                icon: .systemImage("arrow.clockwise")
            ) {
                self.viewModel.loadData(showHud: true)
            }
            .runePadding(.horizontal, LLSpacing.pageInset)

        }

    }

    @ContentBuilder
    private func promotions() -> some View {

        if !self.viewModel.promotions.isEmpty {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                sectionHeader(String(localized: "Promotions"))
                StorePromotionsCarousel(promotions: self.viewModel.promotions) { [weak viewModel] promotion in
                    viewModel?.openPromotion(promotion)
                }

            }
            .transition(AnyTransition(.blurReplace))
            .compositingGroup()
            .geometryGroup()

        }

    }

    @ContentBuilder
    private func featuredProducts() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            featuredProductsHeader()

            if !self.viewModel.featuredProducts.isEmpty {

                featuredCarousel()

            } else if self.viewModel.hasCompletedInitialLoad {

                CommerceEmptyState(
                    systemImage: "bag",
                    title: String(localized: "No Featured Products"),
                    message: String(localized: "Products will appear here when available at this location.")
                )
                .runePadding(.horizontal, LLSpacing.pageInset)

            }

        }
        .compositingGroup()
        .geometryGroup()

    }

    @ContentBuilder
    private func featuredProductsHeader() -> some View {

        CommerceSectionHeader(
            title: String(localized: "Featured Products"),
            actionTitle: String(localized: "Browse Menu"),
            action: { self.tabBarNavigationService.select(.tab2) }
        )
        .runePadding(.horizontal, LLSpacing.pageInset)
        .compositingGroup()
        .geometryGroup()

    }

    @ContentBuilder
    private func featuredCarousel() -> some View {

        ScrollView(.horizontal) {

            LazyHStack(
                alignment: .top,
                spacing: self.style.spacing(LLSpacing.cardContent)
            ) {

                ForEach(self.viewModel.featuredProducts) { product in
                    featuredProductCard(product)
                }

            }
            .scrollTargetLayout()

        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .safeAreaPadding(
            .horizontal,
            self.style.spacing(LLSpacing.listRow)
        )
        .compositingGroup()
        .geometryGroup()

    }

    @ContentBuilder
    private func featuredProductCard(_ product: Product) -> some View {

        ProductCardView(
            product: product,
            isFavorite: self.viewModel.favoriteProductIds.contains(product.id),
            onOpen: { self.viewModel.openFeaturedProduct(id: product.id) },
            onFavorite: { self.viewModel.toggleFavorite(id: product.id) }
        )
        .containerRelativeFrame(
            .horizontal,
            count: self.dynamicTypeSize.isAccessibilitySize ? 1 : 2,
            spacing: self.style.spacing(LLSpacing.cardContent)
        )

    }

    @ContentBuilder
    private func events() -> some View {

        if !self.viewModel.events.isEmpty {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                eventsHeader()
                eventCarousel()

            }
            .transition(AnyTransition(.blurReplace))
            .compositingGroup()
            .geometryGroup()

        }

    }

    @ContentBuilder
    private func eventsHeader() -> some View {

        CommerceSectionHeader(
            title: String(localized: "Upcoming Events"),
            actionTitle: String(localized: "See All"),
            action: { [weak viewModel] in viewModel?.openEvents() }
        )
        .runePadding(.horizontal, LLSpacing.pageInset)
        .compositingGroup()
        .geometryGroup()

    }

    @ContentBuilder
    private func eventCarousel() -> some View {

        if !self.viewModel.events.isEmpty {

            ScrollView(.horizontal) {

                LazyHStack(
                    alignment: .top,
                    spacing: self.style.spacing(LLSpacing.groupedContent)
                ) {

                    ForEach(self.viewModel.events) { event in
                        eventCard(event)
                    }

                }
                .scrollTargetLayout()

            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .safeAreaPadding(
                .horizontal,
                self.style.spacing(LLSpacing.listRow)
            )
            .compositingGroup()
            .geometryGroup()

        }

    }

    @ContentBuilder
    private func eventCard(_ event: StoreEvent) -> some View {

        StoreEventCard(
            event: event,
            location: self.viewModel.locationDetails?.location
        ) { [weak viewModel] in
            viewModel?.openEvent(event)
        }
        .containerRelativeFrame(
            .horizontal,
            count: self.dynamicTypeSize.isAccessibilitySize ? 1 : 3,
            span: self.dynamicTypeSize.isAccessibilitySize ? 1 : 2,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        )

    }

}

#Preview {

    StoreDetailsScreen(
        viewModel: mockResolve(StoreDetailsViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
