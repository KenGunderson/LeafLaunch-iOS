import Combine
import SwiftUI

@MainActor
final class StoreDetailsViewModel: ViewModel {

    let loggerName: String = "STORE_DETAILS_VIEW_MODEL"
    let loggerEmoji: String = "🏪"

    private let apiService: APIServiceProtocol
    private let storeSessionService: StoreSessionServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var loadOverviewTask: Task<Void, Never>?
    private var favoritesSubscription: AnyCancellable?

    @Published private(set) var promotions: [Promotion] = []
    @Published private(set) var events: [StoreEvent] = []
    @Published private(set) var featuredProducts: [Product] = []
    @Published private(set) var favoriteProductIds: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasCompletedInitialLoad: Bool = false

    var configuration: CustomerBootstrap? { self.storeSessionService.configuration }
    var store: PublicStore? { self.storeSessionService.store }
    var locationDetails: CustomerLocationDetails? { self.storeSessionService.locationDetails }

    init(apiService: APIServiceProtocol,
         storeSessionService: StoreSessionServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol) {

        self.apiService = apiService
        self.storeSessionService = storeSessionService
        self.userDefaultsService = userDefaultsService
        self.analyticsService = analyticsService
        self.alertService = alertService

        logInit()

    }

    isolated deinit {

        self.loadOverviewTask?.cancel()
        self.favoritesSubscription?.cancel()
        logDeinit()

    }

    @discardableResult
    func setup(locationId: String) -> Self {

        self.locationId = locationId
        return self

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()
        bindSubscribers()

    }

    func loadData(showHud: Bool) {

        guard self.loadOverviewTask == nil,
              let locationId = self.locationId else { return }

        let apiService = self.apiService
        let alertService = self.alertService
        let featuredQuery = ProductQuery(sort: .featured, limit: 6)
        self.isLoading = true

        self.loadOverviewTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                self?.isLoading = false
                self?.loadOverviewTask = nil

            }

            do {

                async let promotions = apiService.getCustomerPromotions(locationId: locationId)
                async let events = apiService.getCustomerEvents(locationId: locationId, offset: 0, limit: 10)
                async let featuredProducts = apiService.getCustomerProducts(locationId: locationId, query: featuredQuery)
                let (loadedPromotions, loadedEvents, loadedFeaturedProducts) = try await (promotions, events, featuredProducts)
                guard !Task.isCancelled else { return }

                self?.promotions = loadedPromotions
                self?.events = Array(loadedEvents.data.prefix(10))
                self?.featuredProducts = loadedFeaturedProducts.data
                self?.hasCompletedInitialLoad = true

            } catch {

                guard !Task.isCancelled else { return }
                self?.presentOverviewError(context: .get)

            }

        }

    }

    func changeLocation() {
        self.storeSessionService.showLocations()
    }

    func openEvents() {

        guard let locationId = self.locationId else { return }
        self.navigationService?.push(.customer(.events(locationId: locationId)))

    }

    func openEvent(_ event: StoreEvent) {

        guard let locationId = self.locationId,
              self.events.contains(where: { $0.id == event.id }) else { return }

        self.navigationService?.push(.customer(.event(locationId: locationId, event: event)))

    }

    func openPromotion(_ promotion: Promotion) {

        guard let locationId = self.locationId,
              self.promotions.contains(where: { $0.id == promotion.id }) else { return }

        switch promotion.kind {
        case .general:
            return

        case .sale, .newProduct:

            guard !promotion.linkedProducts.isEmpty else {

                presentPromotionError(message: Constants.Message.promotionProductsErrorMessage)
                return

            }

            if promotion.linkedProducts.count == 1, let product = promotion.linkedProducts.first {

                guard let listingId = product.locationProductListingId else {

                    presentPromotionError(message: Constants.Message.promotionProductUnavailableMessage)
                    return

                }

                self.navigationService?.push(.customer(.product(locationId: locationId, productId: listingId)))

            } else {

                self.navigationService?.push(.customer(.promotionProducts(
                    locationId: locationId,
                    promotionId: promotion.id,
                    title: promotion.title,
                    products: promotion.linkedProducts
                )))

            }

        case .link:
            openPromotionLink(promotion.url)

        }

    }

    func openFeaturedProduct(id: String) {

        guard let locationId = self.locationId,
              self.featuredProducts.contains(where: { $0.id == id }) else { return }
        self.navigationService?.push(.customer(.product(locationId: locationId, productId: id)))

    }

    func toggleFavorite(id: String) {

        guard let product = self.featuredProducts.first(where: { $0.id == id }) else { return }

        let isFavorite = !self.favoriteProductIds.contains(id)
        self.userDefaultsService.setFavorite(
            productId: id,
            isFavorite: isFavorite
        )
        presentFavoriteToast(title: product.displayName, isFavorite: isFavorite)

    }

    private func bindSubscribers() {

        guard self.favoritesSubscription == nil else { return }

        self.favoritesSubscription = self.userDefaultsService.favoriteProductIdsPublisher
            .sink { [weak self] in self?.favoriteProductIds = $0 }

    }

    private func presentOverviewError(context: Constants.Message.Context) {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.errorMessage(context: context, "store information"),
                    action: {}
                )
            )
        ))
        
    }

    private func openPromotionLink(_ value: String?) {

        guard let value,
              let components = URLComponents(string: value),
              components.scheme?.lowercased() == "https",
              let host = components.host,
              !host.isEmpty,
              let url = components.url else {

            presentPromotionError(message: Constants.Message.promotionLinkErrorMessage)
            return

        }

        UIApplication.shared.open(url, options: [:]) { [weak self] didOpen in

            guard !didOpen else { return }
            self?.presentPromotionError(message: Constants.Message.promotionLinkErrorMessage)

        }

    }

    private func presentPromotionError(message: String) {

        self.alertService.showAlert(.init(
            .appAlert(.error(message: message, action: {}))
        ))

    }
    
    private func presentFavoriteToast(title: String, isFavorite: Bool) {
        
        ToastManager.shared.present(toastItem: .init(
            timing: .medium,
            direction: .top,
            content: {
                
                ProductFavoriteToastView(
                    productTitle: title,
                    isFavorite: isFavorite
                )
                
            }
            
        ))
        
    }

}

extension StoreDetailsViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.overview(locationId: locationId)))

    }

}
