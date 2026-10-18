import Combine
import SwiftUI
import UIKit

@MainActor
final class ProductDetailsViewModel: ViewModel {

    let loggerName: String = "PRODUCT_DETAILS_VIEW_MODEL"
    let loggerEmoji: String = "📦"

    private let apiService: APIServiceProtocol
    private let storeSessionService: StoreSessionServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var productId: String?
    private var loadProductTask: Task<Void, Never>?
    private var loadRecommendationsTask: Task<Void, Never>?
    private var favoritesSubscription: AnyCancellable?

    @Published private(set) var product: Product?
    @Published private(set) var recommendedProducts: [Product] = []
    @Published private(set) var favoriteProductIds: Set<String> = []
    @Published private(set) var isFavorite: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasLoadFailed: Bool = false

    var storeName: String {

        if let details = self.storeSessionService.locationDetails,
           details.location.id == self.locationId {
            return details.location.name
        }

        return self.storeSessionService.store?.name ?? String(localized: "Store")

    }

    var canOpenMaps: Bool {
        self.directionsURL != nil
    }

    var canCallStore: Bool {
        self.phoneURL != nil
    }

    var canEmailStore: Bool {
        self.emailURL != nil
    }

    private var directionsURL: URL? {

        guard let details = self.storeSessionService.locationDetails,
              details.location.id == self.locationId else { return nil }

        let address = details.address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty else { return nil }

        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [URLQueryItem(name: "q", value: address)]
        return components?.url

    }

    private var phoneURL: URL? {

        guard let phone = self.storeSessionService.store?.supportPhone?.trimmingCharacters(in: .whitespacesAndNewlines),
              !phone.isEmpty else { return nil }

        var components = URLComponents()
        components.scheme = "tel"
        components.path = phone
        return components.url

    }

    private var emailURL: URL? {

        guard let email = self.storeSessionService.store?.supportEmail?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else { return nil }

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = email
        return components.url

    }

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

        self.loadProductTask?.cancel()
        self.loadRecommendationsTask?.cancel()
        self.favoritesSubscription?.cancel()
        logDeinit()

    }

    @discardableResult
    func setup(locationId: String, productId: String) -> Self {

        if self.locationId != locationId || self.productId != productId {

            self.loadProductTask?.cancel()
            self.loadProductTask = nil
            self.loadRecommendationsTask?.cancel()
            self.loadRecommendationsTask = nil
            self.product = nil
            self.recommendedProducts = []
            self.isLoading = false
            self.hasLoadFailed = false

        }

        self.locationId = locationId
        self.productId = productId
        self.isFavorite = self.favoriteProductIds.contains(productId)
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

        guard self.loadProductTask == nil,
              let locationId = self.locationId,
              let productId = self.productId else { return }

        let apiService = self.apiService
        let alertService = self.alertService
        self.isLoading = true
        self.hasLoadFailed = false

        self.loadProductTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                if !Task.isCancelled {

                    self?.isLoading = false
                    self?.loadProductTask = nil

                }

            }

            do {

                let product = try await apiService.getCustomerProduct(locationId: locationId, productId: productId)
                guard !Task.isCancelled else { return }

                self?.product = product
                self?.loadRecommendedProducts(for: product)

            } catch {

                guard !Task.isCancelled else { return }
                self?.hasLoadFailed = true
                self?.presentProductError(context: .get)

            }

        }

    }

    func toggleFavorite() {

        guard let product = self.product else { return }
        toggleFavorite(product)

    }

    func toggleFavorite(_ product: Product) {

        guard product.id == self.product?.id || self.recommendedProducts.contains(where: { $0.id == product.id }) else { return }

        let isFavorite = !self.favoriteProductIds.contains(product.id)
        self.userDefaultsService.setFavorite(productId: product.id, isFavorite: isFavorite)
        presentFavoriteToast(title: product.displayName, isFavorite: isFavorite)

    }

    func openProduct(_ product: Product) {

        guard let locationId = self.locationId,
              self.recommendedProducts.contains(where: { $0.id == product.id }) else { return }
        self.navigationService?.push(.customer(.product(locationId: locationId, productId: product.id)))

    }

    func openMaps() {

        guard let url = self.directionsURL else { return }

        UIApplication.shared.open(url, options: [:]) { [weak self] didOpen in

            guard !didOpen else { return }
            self?.presentContactError(message: Constants.Message.storeDirectionsErrorMessage)

        }

    }

    func callStore() {

        guard let url = self.phoneURL else { return }

        UIApplication.shared.open(url, options: [:]) { [weak self] didOpen in

            guard !didOpen else { return }
            self?.presentContactError(message: Constants.Message.storePhoneErrorMessage)

        }

    }

    func emailStore() {

        guard let url = self.emailURL else { return }

        UIApplication.shared.open(url, options: [:]) { [weak self] didOpen in

            guard !didOpen else { return }
            self?.presentContactError(message: Constants.Message.storeEmailErrorMessage)

        }

    }

    func dismiss() {
        self.navigationService?.pop()
    }

    private func bindSubscribers() {

        guard self.favoritesSubscription == nil else { return }

        self.favoritesSubscription = self.userDefaultsService.favoriteProductIdsPublisher
            .sink { [weak self] favoriteIds in

                self?.favoriteProductIds = favoriteIds
                guard let productId = self?.productId else { return }
                self?.isFavorite = favoriteIds.contains(productId)

            }

    }

    private func loadRecommendedProducts(for product: Product) {

        self.loadRecommendationsTask?.cancel()
        self.loadRecommendationsTask = nil

        guard let locationId = self.locationId,
              let categoryId = product.category?.id else {

            self.recommendedProducts = []
            return

        }

        let apiService = self.apiService
        let productId = product.id
        let query = ProductQuery(categoryId: categoryId, sort: .featured, limit: 7)

        self.recommendedProducts = self.recommendedProducts.filter {
            $0.id != productId && $0.category?.id == categoryId
        }

        self.loadRecommendationsTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            defer {

                if !Task.isCancelled {
                    self?.loadRecommendationsTask = nil
                }

            }

            do {

                let page = try await apiService.getCustomerProducts(locationId: locationId, query: query)
                guard !Task.isCancelled,
                      self?.locationId == locationId,
                      self?.product?.id == productId else { return }

                self?.recommendedProducts = Array(page.data.filter {
                    $0.id != productId && $0.category?.id == categoryId
                }.prefix(6))

            } catch {

                guard !Task.isCancelled,
                      self?.locationId == locationId,
                      self?.product?.id == productId else { return }

                // Recommendations are optional; retain existing results if their refresh fails.
                self?.logError(title: "Recommended Products Error", message: error.getMessageForError())

            }

        }

    }

    private func presentContactError(message: String) {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(message: message, action: {})
            )
        ))

    }

    private func presentProductError(context: Constants.Message.Context) {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.errorMessage(context: context, "product"),
                    action: {}
                )
            )
        ))

    }

    private func presentFavoriteToast(title: String, isFavorite: Bool) {

        ToastManager.shared.present(toastItem: .init(
            timing: .medium,
            direction: .top,
            content: { ProductFavoriteToastView(productTitle: title, isFavorite: isFavorite) }
        ))

    }

}

extension ProductDetailsViewModel {

    func track() {

        guard let locationId = self.locationId, let productId = self.productId else { return }
        self.analyticsService.track(screen: .customer(.product(locationId: locationId, productId: productId)))

    }

}
