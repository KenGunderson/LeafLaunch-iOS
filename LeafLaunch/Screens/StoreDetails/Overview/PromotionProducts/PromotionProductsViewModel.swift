import SwiftUI

@MainActor
final class PromotionProductsViewModel: ViewModel {

    let loggerName: String = "PROMOTION_PRODUCTS_VIEW_MODEL"
    let loggerEmoji: String = "🏷️"

    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var promotionId: String?

    @Published private(set) var title: String = ""
    @Published private(set) var products: [PromotionLinkedProduct] = []

    init(analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol) {

        self.analyticsService = analyticsService
        self.alertService = alertService

        logInit()

    }

    isolated deinit {
        logDeinit()
    }

    @discardableResult
    func setup(locationId: String,
               promotionId: String,
               title: String,
               products: [PromotionLinkedProduct]) -> Self {

        self.locationId = locationId
        self.promotionId = promotionId
        self.title = title
        self.products = products
        return self

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {
        track()
    }

    func openProduct(_ product: PromotionLinkedProduct) {

        guard let locationId = self.locationId,
              self.products.contains(where: { $0.id == product.id }) else { return }

        guard let listingId = product.locationProductListingId else {

            presentUnavailableProduct()
            return

        }

        self.navigationService?.push(.customer(.product(locationId: locationId, productId: listingId)))

    }

    func dismiss() {
        self.navigationService?.pop()
    }

    private func presentUnavailableProduct() {

        self.alertService.showAlert(.init(
            .appAlert(.error(message: Constants.Message.promotionProductUnavailableMessage, action: {}))
        ))

    }

}

extension PromotionProductsViewModel {

    func track() {

        guard let locationId = self.locationId, let promotionId = self.promotionId else { return }
        self.analyticsService.track(screen: .customer(.promotionProducts(locationId: locationId, promotionId: promotionId)))

    }

}
