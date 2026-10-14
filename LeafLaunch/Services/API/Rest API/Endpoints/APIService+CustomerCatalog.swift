import Foundation

extension APIService {

    @concurrent
    func getCustomerCategories(locationId: String) async throws -> [ProductCategory] {

        var categories: [ProductCategory] = []
        var offset = 0

        while true {

            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .customerPublic("locations/\(locationId)/categories")),
                queryParameters: ["limit": "100", "offset": String(offset)],
                requiresAuthentication: false
            )
            let response: CustomerPage<ProductCategory> = try await parseData(data: data)
            try Task.checkCancellation()

            categories.append(contentsOf: response.data)

            guard response.page.hasMore else { break }
            guard let nextOffset = response.page.nextOffset, nextOffset > offset else {
                throw APIError.decodingError
            }

            offset = nextOffset

        }

        return categories.sorted { ($0.displayOrder, $0.id) < ($1.displayOrder, $1.id) }

    }

    @concurrent
    func getCustomerProducts(locationId: String, query: ProductQuery) async throws -> CustomerPage<Product> {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .customerPublic("locations/\(locationId)/products")),
            queryParameters: query.parameters,
            requiresAuthentication: false
        )
        let response: CustomerPage<Product> = try await parseData(data: data)
        try Task.checkCancellation()

        guard response.data.allSatisfy({ $0.storeLocationId.lowercased() == locationId.lowercased() }) else {
            throw APIError.decodingError
        }

        return response

    }

    @concurrent
    func getCustomerProduct(locationId: String, productId: String) async throws -> Product {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .customerPublic("locations/\(locationId)/products/\(productId)")),
            requiresAuthentication: false
        )
        let product: Product = try await parseData(data: data)
        try Task.checkCancellation()

        guard product.id.lowercased() == productId.lowercased(),
              product.storeLocationId.lowercased() == locationId.lowercased() else {
            throw APIError.decodingError
        }

        return product

    }

    @concurrent
    func getCustomerProductImageURL(locationId: String, productId: String, mediaId: String) async throws -> URL {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .customerPublic("locations/\(locationId)/products/\(productId)/media/\(mediaId)/url")),
            requiresAuthentication: false
        )
        let response: CustomerMediaURL = try await parseData(data: data)
        try Task.checkCancellation()

        return response.url

    }

}
