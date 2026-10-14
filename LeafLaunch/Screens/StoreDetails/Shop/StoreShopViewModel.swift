import Combine
import SwiftUI

@MainActor
final class StoreShopViewModel: ViewModel {

    let loggerName: String = "STORE_SHOP_VIEW_MODEL"
    let loggerEmoji: String = "🛍️"

    private let apiService: APIServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var loadProductsTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var loadId: UUID?
    private var favoritesSubscription: AnyCancellable?
    private var nextOffset: Int?
    private var hasLoadedCategories: Bool = false

    @Published private(set) var categories: [ProductCategory] = []
    @Published private(set) var products: [Product] = []
    @Published private(set) var selectedCategoryId: String?
    @Published private(set) var selectedSubcategoryId: String?
    @Published private(set) var favoriteProductIds: Set<String> = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var hasCompletedInitialLoad: Bool = false
    @Published private(set) var hasMoreProducts: Bool = false
    @Published var search: String = "" {

        didSet {

            guard self.search != oldValue else { return }
            scheduleSearch()

        }

    }

    @Published var sort: ProductSort = .featured {

        didSet {

            guard self.sort != oldValue else { return }
            loadData(showHud: false)

        }

    }

    var subcategories: [ProductSubcategory] {
        return self.categories.first(where: { $0.id == self.selectedCategoryId })?.subcategories ?? []
    }

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

        self.loadProductsTask?.cancel()
        self.searchTask?.cancel()
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

    func selectCategory(id: String?) {

        guard self.selectedCategoryId != id else { return }
        guard id == nil || self.categories.contains(where: { $0.id == id }) else { return }

        self.selectedCategoryId = id
        self.selectedSubcategoryId = nil
        loadData(showHud: false)

    }

    func selectSubcategory(id: String?) {

        guard self.selectedSubcategoryId != id else { return }
        guard id == nil || self.subcategories.contains(where: { $0.id == id }) else { return }

        self.selectedSubcategoryId = id
        loadData(showHud: false)

    }

    func loadData(showHud: Bool) {

        self.searchTask?.cancel()
        self.searchTask = nil
        loadProducts(reset: true, showHud: showHud)

    }

    func clearSearch() {

        self.search = ""
        loadData(showHud: false)

    }

    func loadMore(showHud: Bool = false) {

        guard self.hasMoreProducts else { return }
        loadProducts(reset: false, showHud: showHud)

    }

    func openProduct(id: String) {

        guard let locationId = self.locationId else { return }
        self.navigationService?.push(.customer(.product(locationId: locationId, productId: id)))

    }

    func toggleFavorite(id: String) {

        self.userDefaultsService.setFavorite(
            productId: id,
            isFavorite: !self.favoriteProductIds.contains(id)
        )

    }

    private func loadProducts(reset: Bool, showHud: Bool) {

        guard let locationId = self.locationId else { return }
        guard reset || self.loadProductsTask == nil else { return }

        self.loadProductsTask?.cancel()

        let apiService = self.apiService
        let alertService = self.alertService
        let loadId = UUID()
        let needsCategories = !self.hasLoadedCategories
        let query = ProductQuery(
            search: self.search,
            categoryId: self.selectedCategoryId,
            subcategoryId: self.selectedSubcategoryId,
            sort: self.sort,
            offset: reset ? 0 : (self.nextOffset ?? 0),
            limit: 100
        )

        self.loadId = loadId
        self.isLoading = true

        if reset {

            self.products = []
            self.nextOffset = nil
            self.hasMoreProducts = false
            self.hasCompletedInitialLoad = false

        }

        self.loadProductsTask = Task { [weak self] in

            guard !Task.isCancelled else { return }

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
            if showHud { alertService.showAlert(loadingIndicator) }

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                if self?.loadId == loadId {

                    self?.isLoading = false
                    self?.loadProductsTask = nil

                }

            }

            do {

                if needsCategories {

                    let categories = try await apiService.getCustomerCategories(locationId: locationId)
                    guard !Task.isCancelled, self?.loadId == loadId else { return }

                    self?.categories = categories.sorted { $0.displayOrder < $1.displayOrder }
                    self?.hasLoadedCategories = true

                }

                let page = try await apiService.getCustomerProducts(locationId: locationId, query: query)
                guard !Task.isCancelled, self?.loadId == loadId else { return }

                if reset {

                    var seenIds: Set<String> = []
                    self?.products = page.data.filter { seenIds.insert($0.id).inserted }

                } else {

                    let existingIds = Set(self?.products.map(\.id) ?? [])
                    self?.products.append(contentsOf: page.data.filter { !existingIds.contains($0.id) })

                }

                self?.nextOffset = page.page.nextOffset
                self?.hasMoreProducts = page.page.hasMore &&
                    (page.page.nextOffset ?? query.offset) > query.offset
                self?.hasCompletedInitialLoad = true

            } catch {

                guard !Task.isCancelled, self?.loadId == loadId else { return }
                self?.presentProductsError(context: .get)

            }

        }

    }

    private func scheduleSearch() {

        self.searchTask?.cancel()
        self.loadProductsTask?.cancel()
        self.loadProductsTask = nil
        self.loadId = nil
        self.products = []
        self.nextOffset = nil
        self.hasMoreProducts = false
        self.hasCompletedInitialLoad = false
        self.isLoading = false

        self.searchTask = Task { [weak self] in

            do {

                try await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }

                self?.searchTask = nil
                self?.loadProducts(reset: true, showHud: false)

            } catch {
                return
            }

        }

    }

    private func bindSubscribers() {

        guard self.favoritesSubscription == nil else { return }

        self.favoritesSubscription = self.userDefaultsService.favoriteProductIdsPublisher
            .sink { [weak self] in self?.favoriteProductIds = $0 }

    }

    private func presentProductsError(context: Constants.Message.Context) {

        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: Constants.Message.errorMessage(context: context, "products"),
                    action: {}
                )
            )
        ))

    }

}

extension StoreShopViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.shop(locationId: locationId)))

    }

}
