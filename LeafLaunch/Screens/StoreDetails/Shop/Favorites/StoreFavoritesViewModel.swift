import Combine
import SwiftUI

@MainActor
final class StoreFavoritesViewModel: ViewModel {

    let loggerName: String = "STORE_FAVORITES_VIEW_MODEL"
    let loggerEmoji: String = "❤️"

    private let apiService: APIServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var loadFavoritesTask: Task<Void, Never>?
    private var loadProductImagesTask: Task<Void, Never>?
    private var imageLoadId: UUID?
    private var favoritesSubscription: AnyCancellable?
    private var availableProducts: [Product] = []

    @Published private(set) var products: [Product] = []
    @Published private(set) var imageURLs: [String: URL] = [:]
    @Published private(set) var loadingImageProductIds: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasCompletedInitialLoad: Bool = false
    @Published private(set) var hasLoadFailed: Bool = false

    init(apiService: APIServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol) {
        self.apiService = apiService
        self.userDefaultsService = userDefaultsService
        self.analyticsService = analyticsService
        self.alertService = alertService

        logInit()

    }

    isolated deinit {

        self.loadFavoritesTask?.cancel()
        self.loadProductImagesTask?.cancel()
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

        self.loadFavoritesTask = Task { [weak self] in

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
                self?.imageURLs = [:]
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
        self.userDefaultsService.setFavorite(productId: id, isFavorite: false)
    }

    private func updateFavorites() {

        let favoriteIds = self.userDefaultsService.favoriteProductIds
        self.products = self.availableProducts.filter { favoriteIds.contains($0.id) }
        loadProductImages()

    }

    private func loadProductImages() {

        self.loadProductImagesTask?.cancel()
        self.loadProductImagesTask = nil

        let loadId = UUID()
        let products = self.products.filter { self.imageURLs[$0.id] == nil && !$0.activeImages.isEmpty }
        let apiService = self.apiService

        self.imageLoadId = loadId

        guard let locationId = self.locationId else {

            self.loadingImageProductIds = []
            return

        }

        self.loadingImageProductIds = Set(products.map(\.id))
        guard !products.isEmpty else { return }

        self.loadProductImagesTask = Task { [weak self] in

            defer {

                if !Task.isCancelled, self?.imageLoadId == loadId {

                    self?.loadingImageProductIds = []
                    self?.loadProductImagesTask = nil

                }

            }

            guard !Task.isCancelled, self?.imageLoadId == loadId else { return }

            let loadImage: @Sendable (Product) async -> (productId: String, url: URL?) = { product in

                guard !Task.isCancelled, let media = product.activeImages.first else {
                    return (product.id, nil)
                }

                do {

                    let url = try await apiService.getCustomerProductImageURL(
                        locationId: locationId,
                        productId: product.id,
                        mediaId: media.id
                    )
                    guard !Task.isCancelled else { return (product.id, nil) }

                    return (product.id, url)

                } catch {
                    return (product.id, nil)
                }

            }

            await withTaskGroup(of: (productId: String, url: URL?).self) { group in

                var remainingProducts = products.makeIterator()

                for _ in 0..<min(4, products.count) {

                    guard !Task.isCancelled, self?.imageLoadId == loadId else {

                        group.cancelAll()
                        return

                    }
                    guard let product = remainingProducts.next() else { break }

                    group.addTask { await loadImage(product) }

                }

                while let result = await group.next() {

                    guard !Task.isCancelled, self?.imageLoadId == loadId else {

                        group.cancelAll()
                        return

                    }

                    if let url = result.url {
                        self?.imageURLs[result.productId] = url
                    }

                    self?.loadingImageProductIds.remove(result.productId)

                    if let product = remainingProducts.next() {
                        group.addTask { await loadImage(product) }
                    }

                }

            }

        }

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

}

extension StoreFavoritesViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.favorites(locationId: locationId)))

    }

}
