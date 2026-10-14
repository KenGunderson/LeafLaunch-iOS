import Foundation

extension MockAPIService {

    func signOutCustomerDevice(installationId: String) async throws {}

    func getCustomerBootstrap(appKey: String) async throws -> CustomerBootstrap {

        guard appKey == MockCustomerModels.appKey else { throw customerNotFound() }
        return MockCustomerModels.bootstrap

    }

    func getCustomerLocation(businessId: String, locationId: String) async throws -> CustomerLocationDetails {

        guard businessId == MockCustomerModels.businessId,
              let details = MockCustomerModels.locationDetails(for: locationId) else {
            throw customerNotFound()
        }

        return details

    }

    func getCustomerCategories(locationId: String) async throws -> [ProductCategory] {

        try validateCustomerLocation(locationId)
        let categoryIds = Set(MockCustomerModels.products(locationId: locationId).compactMap { $0.category?.id })
        return MockCustomerModels.categories.filter { categoryIds.contains($0.id) }

    }

    func getCustomerProducts(locationId: String, query: ProductQuery) async throws -> CustomerPage<Product> {

        try validateCustomerLocation(locationId)
        let search = query.search.trimmingCharacters(in: .whitespacesAndNewlines)

        let products = MockCustomerModels.products(locationId: locationId).filter { product in

            let categoryMatches = query.categoryId == nil || product.category?.id == query.categoryId
            let subcategoryMatches = query.categoryId == nil
                || query.subcategoryId == nil
                || product.subcategory?.id == query.subcategoryId
            let searchMatches = search.isEmpty
                || product.displayName.localizedCaseInsensitiveContains(search)
                || product.description?.localizedCaseInsensitiveContains(search) == true
                || product.attributes.contains { $0.value.displayValue.localizedCaseInsensitiveContains(search) }

            return categoryMatches && subcategoryMatches && searchMatches

        }

        return customerPage(products, offset: query.offset, limit: query.limit)

    }

    func getCustomerProduct(locationId: String, productId: String) async throws -> Product {

        try validateCustomerLocation(locationId)
        guard let product = MockCustomerModels.products(locationId: locationId).first(where: { $0.id == productId }) else {
            throw customerNotFound()
        }

        return product

    }

    func getCustomerProductImageURL(locationId: String, productId: String, mediaId: String) async throws -> URL {

        let product = try await getCustomerProduct(locationId: locationId, productId: productId)
        guard let media = product.media?.first(where: { $0.id == mediaId }) else {
            throw customerNotFound()
        }

        return MockCustomerModels.imageURL(seed: "\(product.storeProductId)-\(media.displayOrder)")

    }

    func getCustomerPromotions(locationId: String) async throws -> [Promotion] {

        try validateCustomerLocation(locationId)
        return MockCustomerModels.promotions(locationId: locationId)

    }

    func getCustomerEvents(locationId: String, offset: Int) async throws -> CustomerPage<StoreEvent> {

        try validateCustomerLocation(locationId)
        return customerPage(MockCustomerModels.events(locationId: locationId), offset: offset)

    }

    func getCustomerAccount() async throws -> CustomerAccount {

        guard self.customerAccount.status != .anonymized else { throw customerNotFound() }
        return self.customerAccount

    }

    func registerCustomerAccount(locationId: String, displayName: String) async throws -> CustomerAccount {

        try validateCustomerLocation(locationId)
        let displayName = try validatedDisplayName(displayName)
        try Task.checkCancellation()

        self.customerAccount = MockCustomerModels.newAccount(displayName: displayName)
        self.customerMemberships = [
            locationId: MockCustomerModels.membership(locationId: locationId, customerAccount: self.customerAccount)
        ]

        return self.customerAccount

    }

    func updateCustomerAccount(displayName: String) async throws -> CustomerAccount {

        _ = try await getCustomerAccount()
        let displayName = try validatedDisplayName(displayName)
        try Task.checkCancellation()

        let account = self.customerAccount
        self.customerAccount = CustomerAccount(
            id: account.id,
            accountId: account.accountId,
            displayName: displayName,
            status: .active,
            anonymizedAt: nil,
            createdAt: account.createdAt,
            updatedAt: Date()
        )

        return self.customerAccount

    }

    func deleteCustomerAccount() async throws {

        try Task.checkCancellation()
        let account = self.customerAccount
        self.customerAccount = CustomerAccount(
            id: account.id,
            accountId: account.accountId,
            displayName: "Deleted customer",
            status: .anonymized,
            anonymizedAt: Date(),
            createdAt: account.createdAt,
            updatedAt: Date()
        )
        self.customerMemberships.removeAll()

    }

    func getCustomerMembership(locationId: String) async throws -> CustomerLocationMembership {

        try validateCustomerLocation(locationId)
        _ = try await getCustomerAccount()

        guard let membership = self.customerMemberships[locationId],
              membership.customerAccountId == self.customerAccount.id else {
            throw customerNotFound()
        }

        return MockCustomerModels.membership(
            locationId: membership.storeLocationId,
            customerAccount: self.customerAccount,
            existingMembership: membership
        )

    }

    func joinCustomerMembership(locationId: String) async throws -> CustomerLocationMembership {

        try validateCustomerLocation(locationId)
        _ = try await getCustomerAccount()

        if self.customerMemberships[locationId] != nil {
            return try await getCustomerMembership(locationId: locationId)
        }

        try Task.checkCancellation()
        let membership = MockCustomerModels.membership(locationId: locationId, customerAccount: self.customerAccount)
        self.customerMemberships[locationId] = membership
        return membership

    }

    func getCustomerLoyaltyHistory(locationId: String, offset: Int) async throws -> CustomerPage<LoyaltyHistoryEntry> {

        _ = try await getCustomerMembership(locationId: locationId)
        let history = self.customerAccount.id == MockCustomerModels.account.id ? MockCustomerModels.loyaltyHistory : []
        return customerPage(history, offset: offset)

    }

    private func validateCustomerLocation(_ locationId: String) throws {

        guard MockCustomerModels.locationDetails(for: locationId) != nil else { throw customerNotFound() }

    }

    private func customerNotFound() -> APIError {
        .serverError(statusCode: 404, errorMessage: "The requested customer resource is unavailable.")
    }

    private func validatedDisplayName(_ displayName: String) throws -> String {

        let displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !displayName.isEmpty, displayName.count <= 120 else {
            throw APIError.serverError(statusCode: 400, errorMessage: "Enter a display name with 1–120 characters.")
        }

        return displayName

    }

    private func customerPage<Value: Codable & Sendable>(_ values: [Value],
                                                        offset: Int,
                                                        limit: Int = 20) -> CustomerPage<Value> {

        let offset = max(0, offset)
        let limit = min(100, max(1, limit))
        let data = Array(values.dropFirst(offset).prefix(limit))
        let nextOffset = offset + data.count
        let hasMore = nextOffset < values.count

        return CustomerPage(
            data: data,
            page: CustomerPageMetadata(
                limit: limit,
                offset: offset,
                hasMore: hasMore,
                nextOffset: hasMore ? nextOffset : nil
            )
        )

    }

}
