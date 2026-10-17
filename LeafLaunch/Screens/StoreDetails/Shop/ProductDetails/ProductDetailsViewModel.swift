import Combine
import SwiftUI

@MainActor
final class ProductDetailsViewModel: ViewModel {

    let loggerName: String = "PRODUCT_DETAILS_VIEW_MODEL"
    let loggerEmoji: String = "📦"

    private let apiService: APIServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var productId: String?
    private var loadProductTask: Task<Void, Never>?
    private var favoritesSubscription: AnyCancellable?

    @Published private(set) var product: Product?
    @Published private(set) var isFavorite: Bool = false
    @Published private(set) var isLoading: Bool = false
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

        self.loadProductTask?.cancel()
        self.favoritesSubscription?.cancel()
        logDeinit()

    }

    @discardableResult
    func setup(locationId: String, productId: String) -> Self {

        self.locationId = locationId
        self.productId = productId
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

                self?.isLoading = false
                self?.loadProductTask = nil

            }

            do {

                let product = try await apiService.getCustomerProduct(locationId: locationId, productId: productId)
                guard !Task.isCancelled else { return }

                self?.product = product

            } catch {

                guard !Task.isCancelled else { return }
                self?.hasLoadFailed = true
                self?.presentProductError(context: .get)

            }

        }

    }

    func toggleFavorite() {

        guard let productId = self.productId else { return }
        self.userDefaultsService.setFavorite(productId: productId, isFavorite: !self.isFavorite)

    }

    func dismiss() {
        self.navigationService?.pop()
    }

    private func bindSubscribers() {

        guard self.favoritesSubscription == nil else { return }

        self.favoritesSubscription = self.userDefaultsService.favoriteProductIdsPublisher
            .sink { [weak self] favoriteIds in

                guard let productId = self?.productId else { return }
                self?.isFavorite = favoriteIds.contains(productId)

            }

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

}

extension ProductDetailsViewModel {

    func track() {

        guard let locationId = self.locationId, let productId = self.productId else { return }
        self.analyticsService.track(screen: .customer(.product(locationId: locationId, productId: productId)))

    }

}
