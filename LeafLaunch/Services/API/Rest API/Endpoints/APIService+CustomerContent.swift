import Foundation

extension APIService {

    @concurrent
    func getCustomerPromotions(locationId: String) async throws -> [Promotion] {

        var promotions: [Promotion] = []
        var offset = 0

        while true {

            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .customerPublic("locations/\(locationId)/promotions")),
                queryParameters: ["limit": "100", "offset": String(offset)],
                requiresAuthentication: false
            )
            let response: CustomerPage<Promotion> = try await parseData(data: data)
            try Task.checkCancellation()

            promotions.append(contentsOf: response.data)

            guard response.page.hasMore else { break }
            guard let nextOffset = response.page.nextOffset, nextOffset > offset else {
                throw APIError.decodingError
            }

            offset = nextOffset

        }

        return promotions.sorted { ($0.displayOrder, $0.id) < ($1.displayOrder, $1.id) }

    }

    @concurrent
    func getCustomerEvents(locationId: String, offset: Int, limit: Int) async throws -> CustomerPage<StoreEvent> {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .customerPublic("locations/\(locationId)/events")),
            queryParameters: ["limit": String(min(100, max(1, limit))), "offset": String(max(0, offset))],
            requiresAuthentication: false
        )
        let response: CustomerPage<StoreEvent> = try await parseData(data: data)
        try Task.checkCancellation()

        return response

    }

}
