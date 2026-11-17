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

            AppHeaderScrollView(horizontalPadding: .none) {
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
            viewModel?.loadData(showHud: true)
        }

    }

    @ViewBuilder
    private func navHeader() -> some View {

        StoreNavHeader(
            configuration: self.viewModel.configuration,
            subtitle: self.viewModel.locationDetails?.location.name ?? String(localized: "Choose A Location"),
            onSelectLocation: { [weak viewModel] in viewModel?.changeLocation() }
        )

    }

    @ViewBuilder
    private func content(scrollProxy: ScrollViewProxy) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            visitSummary(scrollProxy: scrollProxy)
                .padding(.bottom, .medium)

            storefrontSections()

            storeInfo()
                .id("store-info")

        }
        .foregroundStyle(.text(.body))

    }

    @ViewBuilder
    private func visitSummary(scrollProxy: ScrollViewProxy) -> some View {

        if let details = self.viewModel.locationDetails {

            StoreVisitSummaryView(details: details) {

                withAnimation(self.reduceMotion ? nil : .easeInOut(duration: 0.3)) {
                    scrollProxy.scrollTo("store-info", anchor: .top)
                }

            }
            .padding(.horizontal, .medium)

        }

    }

    @ViewBuilder
    private func storefrontSections() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            promotions()
            featuredProducts()
            events()
            reloadAction()

        }
        .animation(.bouncy, value: self.viewModel.promotions.isEmpty)
        .animation(.bouncy, value: self.viewModel.events.isEmpty)

    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {

        CommerceSectionHeader(title: title)
            .padding(.horizontal, .medium)

    }

    @ViewBuilder
    private func storeInfo() -> some View {

        if self.viewModel.store != nil || self.viewModel.locationDetails != nil {

            StoreInfoView(
                store: self.viewModel.store,
                details: self.viewModel.locationDetails
            )

        }

    }

    @ViewBuilder
    private func reloadAction() -> some View {

        if !self.viewModel.hasCompletedInitialLoad && !self.viewModel.isLoading {

            LeafLaunchButton(
                title: String(localized: "Reload Store"),
                icon: .systemImage("arrow.clockwise")
            ) {
                self.viewModel.loadData(showHud: true)
            }
            .padding(.horizontal, .medium)

        }

    }

    @ViewBuilder
    private func promotions() -> some View {

        if !self.viewModel.promotions.isEmpty {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

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

    @ViewBuilder
    private func featuredProducts() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            featuredProductsHeader()

            if !self.viewModel.featuredProducts.isEmpty {

                featuredCarousel()

            } else if self.viewModel.hasCompletedInitialLoad && !self.viewModel.isLoading {

                CommerceEmptyState(
                    systemImage: "bag",
                    title: String(localized: "No Featured Products"),
                    message: String(localized: "Products will appear here when available at this location.")
                )
                .padding(.horizontal, .medium)

            }

        }
        .compositingGroup()
        .geometryGroup()

    }

    @ViewBuilder
    private func featuredProductsHeader() -> some View {

        CommerceSectionHeader(
            title: String(localized: "Featured Products"),
            actionTitle: String(localized: "Browse Menu"),
            action: { self.tabBarNavigationService.select(.tab2) }
        )
        .padding(.horizontal, .medium)
        .compositingGroup()
        .geometryGroup()

    }

    @ViewBuilder
    private func featuredCarousel() -> some View {

        ScrollView(.horizontal) {

            LazyHStack(alignment: .top, spacing: self.style.spacing(.small2)) {

                ForEach(self.viewModel.featuredProducts) { product in
                    featuredProductCard(product)
                }

            }
            .scrollTargetLayout()

        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .safeAreaPadding(.horizontal, self.style.spacing(.medium))
        .compositingGroup()
        .geometryGroup()

    }

    @ViewBuilder
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
            spacing: self.style.spacing(.small2)
        )

    }

    @ViewBuilder
    private func events() -> some View {

        if !self.viewModel.events.isEmpty {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                eventsHeader()
                eventCarousel()

            }
            .transition(AnyTransition(.blurReplace))
            .compositingGroup()
            .geometryGroup()

        }

    }

    @ViewBuilder
    private func eventsHeader() -> some View {

        CommerceSectionHeader(
            title: String(localized: "Upcoming Events"),
            actionTitle: String(localized: "See All"),
            action: { [weak viewModel] in viewModel?.openEvents() }
        )
        .padding(.horizontal, .medium)
        .compositingGroup()
        .geometryGroup()

    }

    @ViewBuilder
    private func eventCarousel() -> some View {

        if !self.viewModel.events.isEmpty {

            ScrollView(.horizontal) {

                LazyHStack(alignment: .top, spacing: self.style.spacing(.small)) {

                    ForEach(self.viewModel.events) { event in
                        eventCard(event)
                    }

                }
                .scrollTargetLayout()

            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .safeAreaPadding(.horizontal, self.style.spacing(.medium))
            .compositingGroup()
            .geometryGroup()

        }

    }

    @ViewBuilder
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
            spacing: self.style.spacing(.small)
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
