import Combine
import SwiftUI

@MainActor
final class FavoriteProductListViewModel: ViewModel {

    let loggerName: String = "FAVORITE_PRODUCT_LIST_VIEW_MODEL"
    let loggerEmoji: String = "❤️"

    private let apiService: APIServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let tabBarNavigationService: TabBarNavigationService
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var loadFavoritesTask: Task<Void, Never>?
    private var favoritesSubscription: AnyCancellable?
    private var availableProducts: [Product] = []

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasCompletedInitialLoad: Bool = false
    @Published private(set) var hasLoadFailed: Bool = false

    init(apiService: APIServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         tabBarNavigationService: TabBarNavigationService,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol) {

        self.apiService = apiService
        self.userDefaultsService = userDefaultsService
        self.tabBarNavigationService = tabBarNavigationService
        self.analyticsService = analyticsService
        self.alertService = alertService

        logInit()

    }

    isolated deinit {

        self.loadFavoritesTask?.cancel()
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

        guard self.loadFavoritesTask == nil, let locationId = self.locationId else { return }

        let apiService = self.apiService
        let alertService = self.alertService
        self.isLoading = true
        self.hasLoadFailed = false

        self.loadFavoritesTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                self?.isLoading = false
                self?.loadFavoritesTask = nil

            }

            do {

                var query = ProductQuery()
                var products: [Product] = []

                while true {

                    let page = try await apiService.getCustomerProducts(locationId: locationId, query: query)
                    guard !Task.isCancelled else { return }

                    products.append(contentsOf: page.data)
                    guard page.page.hasMore, let offset = page.page.nextOffset,
                          offset > query.offset else { break }

                    query.offset = offset

                }

                guard !Task.isCancelled else { return }

                var seenIds: Set<String> = []
                self?.availableProducts = products.filter { seenIds.insert($0.id).inserted }
                self?.updateFavorites()
                self?.hasCompletedInitialLoad = true

            } catch {

                guard !Task.isCancelled else { return }
                self?.hasLoadFailed = true
                self?.presentFavoritesError(context: .get)

            }

        }

    }

    func openProduct(id: String) {

        guard let locationId = self.locationId else { return }
        self.navigationService?.push(.customer(.product(locationId: locationId, productId: id)))

    }

    func removeFavorite(id: String) {

        guard let product = self.products.first(where: { $0.id == id }),
              self.userDefaultsService.favoriteProductIds.contains(id) else { return }

        self.userDefaultsService.setFavorite(productId: id, isFavorite: false)
        presentFavoriteRemovedToast(productTitle: product.displayName)

    }

    func dismiss() {
        self.navigationService?.pop()
    }

    func browseProducts() {

        self.navigationService?.pop()
        self.tabBarNavigationService.tab2NavigationService.popToRoot()
        self.tabBarNavigationService.select(.tab2)

    }

    private func updateFavorites() {

        let favoriteIds = self.userDefaultsService.favoriteProductIds
        self.products = self.availableProducts.filter { favoriteIds.contains($0.id) }

    }

    private func bindSubscribers() {

        guard self.favoritesSubscription == nil else { return }

        self.favoritesSubscription = self.userDefaultsService.favoriteProductIdsPublisher
            .sink { [weak self] _ in self?.updateFavorites() }

    }

    private func presentFavoritesError(context: Constants.Message.Context) {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.errorMessage(context: context, "favorite products"),
                    action: {}
                )
            )
        ))

    }

    private func presentFavoriteRemovedToast(productTitle: String) {

        ToastManager.shared.present(toastItem: .init(
            timing: .medium,
            direction: .top,
            content: { ProductFavoriteToastView(productTitle: productTitle, isFavorite: false) }
        ))

    }

}

extension FavoriteProductListViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.favorites(locationId: locationId)))

    }

}
