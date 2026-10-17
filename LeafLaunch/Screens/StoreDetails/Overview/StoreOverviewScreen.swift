import SwiftUI

struct StoreOverviewScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: StoreOverviewViewModel

    init(viewModel: StoreOverviewViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .none) {
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
            onSelectLocation: { [weak viewModel] in viewModel?.changeLocation() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            storefrontSections()
            storeInfo()

        }
        .foregroundStyle(.text(.body))

    }

    @ViewBuilder
    private func storefrontSections() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            promotions()
            events()
            featuredProducts()
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

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                sectionHeader(String(localized: "Promotions"))
                StorePromotionsCarousel(promotions: self.viewModel.promotions) { [weak viewModel] promotion in
                    viewModel?.openPromotion(promotion)
                }

            }
            .transition(AnyTransition(.blurReplace))

        }

    }

    @ViewBuilder
    private func featuredProducts() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            sectionHeader(String(localized: "Featured Products"))

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
            count: 5,
            span: 3,
            spacing: self.style.spacing(.small2)
        )

    }

    @ViewBuilder
    private func events() -> some View {

        if !self.viewModel.events.isEmpty {

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                eventsHeader()
                eventCarousel()

            }
            .transition(AnyTransition(.blurReplace))

        }

    }

    @ViewBuilder
    private func eventsHeader() -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            CommerceSectionHeader(title: String(localized: "Events"))

            if !self.viewModel.events.isEmpty {

                Text(String(localized: "View More"))
                    .appFont(with: .TITLE_2)
                    .foregroundStyle(self.style.accent)
                    .fixedSize(horizontal: true, vertical: false)
                    .asButton { [weak viewModel] in viewModel?.openEvents() }

            }

        }
        .padding(.horizontal, .medium)

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
            count: 5,
            span: 3,
            spacing: self.style.spacing(.small)
        )

    }

}

#Preview {

    StoreOverviewScreen(
        viewModel: mockResolve(StoreOverviewViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockPreviews()

}
