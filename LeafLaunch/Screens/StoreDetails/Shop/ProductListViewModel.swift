import Combine
import SwiftUI

@MainActor
final class ProductListViewModel: ViewModel {

    let loggerName: String = "PRODUCT_LIST_VIEW_MODEL"
    let loggerEmoji: String = "🛍️"

    private let apiService: APIServiceProtocol
    private let storeSessionService: StoreSessionServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var locationId: String?
    private var loadProductsTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var loadId: UUID?
    private var activeQuery: ProductQuery?
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
    @Published private(set) var hasLoadFailed: Bool = false
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

    var configuration: CustomerBootstrap? { self.storeSessionService.configuration }
    var locationDetails: CustomerLocationDetails? { self.storeSessionService.locationDetails }

    var hasActiveFilters: Bool {
        !self.search.isEmpty ||
            self.selectedCategoryId != self.categories.first?.id ||
            self.selectedSubcategoryId != self.subcategories.first?.id
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

        guard let category = self.categories.first(where: { $0.id == id }),
              self.selectedCategoryId != category.id else { return }

        self.selectedCategoryId = category.id
        self.selectedSubcategoryId = category.subcategories.first?.id
        loadData(showHud: false)

    }

    func selectSubcategory(id: String?) {

        guard let subcategory = self.subcategories.first(where: { $0.id == id }),
              self.selectedSubcategoryId != subcategory.id else { return }

        self.selectedSubcategoryId = subcategory.id
        loadData(showHud: false)

    }

    func loadData(showHud: Bool) {

        self.searchTask?.cancel()
        self.searchTask = nil
        loadProducts(reset: true, showHud: showHud)

    }

    @discardableResult
    func refresh() async -> Bool? {

        guard !Task.isCancelled else { return nil }

        self.searchTask?.cancel()
        self.searchTask = nil

        guard let loadTask = loadProducts(reset: true, showHud: false, reloadCategories: true) else { return nil }
        let loadId = self.loadId

        await withTaskCancellationHandler {
            await loadTask.value
        } onCancel: {
            loadTask.cancel()
        }

        guard !Task.isCancelled,
              !loadTask.isCancelled,
              self.loadId == loadId else { return nil }

        return !self.hasLoadFailed

    }

    func submitSearch() {

        guard self.searchTask != nil || self.hasLoadFailed else { return }
        loadData(showHud: false)

    }

    func clearSearch() {

        self.search = ""
        loadData(showHud: false)

    }

    func clearFilters() {

        self.search = ""
        self.selectedCategoryId = self.categories.first?.id
        self.selectedSubcategoryId = self.categories.first?.subcategories.first?.id
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

    func openFavorites() {

        guard let locationId = self.locationId else { return }
        self.navigationService?.push(.customer(.favoriteProducts(locationId: locationId)))

    }

    func changeLocation() {
        self.storeSessionService.showLocations()
    }

    func toggleFavorite(id: String) {

        guard let product = self.products.first(where: { $0.id == id }) else { return }

        let isFavorite = !self.favoriteProductIds.contains(id)
        self.userDefaultsService.setFavorite(
            productId: id,
            isFavorite: isFavorite
        )
        presentFavoriteToast(title: product.displayName, isFavorite: isFavorite)

    }

    @discardableResult
    private func loadProducts(reset: Bool, showHud: Bool, reloadCategories: Bool = false) -> Task<Void, Never>? {

        guard let locationId = self.locationId else { return nil }
        guard reset || self.loadProductsTask == nil else { return nil }

        self.loadProductsTask?.cancel()

        let apiService = self.apiService
        let alertService = self.alertService
        let loadId = UUID()
        let needsCategories = reloadCategories || !self.hasLoadedCategories
        let querySnapshot = ProductQuery(
            search: self.search,
            categoryId: self.selectedCategoryId,
            subcategoryId: self.selectedSubcategoryId,
            sort: self.sort,
            offset: reset ? 0 : (self.nextOffset ?? 0),
            limit: 100
        )

        self.loadId = loadId
        self.isLoading = true
        self.hasLoadFailed = false

        let loadTask = Task { @MainActor [weak self] in

            let loadingIndicator = RuneAlert(.simpleLoadingIndicator)

            defer {

                if showHud { alertService.dismissAlert(loadingIndicator) }

                if self?.loadId == loadId {

                    self?.isLoading = false
                    self?.loadProductsTask = nil

                }

            }

            guard !Task.isCancelled else { return }
            if showHud { alertService.showAlert(loadingIndicator) }

            do {

                var query = querySnapshot
                var refreshedCategories: [ProductCategory]?

                if needsCategories {

                    let categories = try await apiService.getCustomerCategories(locationId: locationId)
                    guard !Task.isCancelled, self?.loadId == loadId else { return }

                    let sortedCategories = categories.sorted { $0.displayOrder < $1.displayOrder }
                    let category = sortedCategories.first(where: { $0.id == query.categoryId }) ?? sortedCategories.first
                    let subcategory = category?.subcategories.first(where: { $0.id == query.subcategoryId }) ?? category?.subcategories.first

                    query.categoryId = category?.id
                    query.subcategoryId = subcategory?.id

                    if reloadCategories {

                        refreshedCategories = sortedCategories

                    } else {

                        self?.categories = sortedCategories
                        self?.selectedCategoryId = query.categoryId
                        self?.selectedSubcategoryId = query.subcategoryId
                        self?.hasLoadedCategories = true

                    }

                }

                if reset && !reloadCategories {

                    if self?.activeQuery != query {

                        self?.products = []
                        self?.nextOffset = nil
                        self?.hasMoreProducts = false
                        self?.hasCompletedInitialLoad = false

                    }

                    self?.activeQuery = query

                }

                let page = try await apiService.getCustomerProducts(locationId: locationId, query: query)
                guard !Task.isCancelled, self?.loadId == loadId else { return }

                if let refreshedCategories {

                    self?.categories = refreshedCategories
                    self?.selectedCategoryId = query.categoryId
                    self?.selectedSubcategoryId = query.subcategoryId
                    self?.hasLoadedCategories = true

                }

                if reset {

                    var seenIds: Set<String> = []
                    self?.activeQuery = query
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
                self?.hasLoadFailed = true
                self?.presentProductsError(context: .get)

            }

        }

        self.loadProductsTask = loadTask
        return loadTask

    }

    private func scheduleSearch() {

        self.searchTask?.cancel()
        self.loadProductsTask?.cancel()
        self.loadProductsTask = nil
        self.loadId = nil
        self.activeQuery = nil
        self.products = []
        self.nextOffset = nil
        self.hasMoreProducts = false
        self.hasCompletedInitialLoad = false
        self.hasLoadFailed = false
        self.isLoading = false

        self.searchTask = Task { @MainActor [weak self] in

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

    private func presentFavoriteToast(title: String, isFavorite: Bool) {

        ToastManager.shared.present(toastItem: .init(
            timing: .medium,
            direction: .top,
            content: { ProductFavoriteToastView(productTitle: title, isFavorite: isFavorite) }
        ))

    }

}

extension ProductListViewModel {

    func track() {

        guard let locationId = self.locationId else { return }
        self.analyticsService.track(screen: .customer(.shop(locationId: locationId)))

    }

}
