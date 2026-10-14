import Foundation

extension APIService {

    @concurrent
    func getCustomerAccount() async throws -> CustomerAccount {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .customer("account")),
            headers: await customerHeaders()
        )
        let account: CustomerAccount = try await parseData(data: data)
        try Task.checkCancellation()

        return account

    }

    @concurrent
    func registerCustomerAccount(locationId: String, displayName: String) async throws -> CustomerAccount {

        let data = try await buildRequest(
            method: .post,
            apiPath: .init(path: .customer("locations/\(locationId)/account")),
            parameters: ["display_name": displayName],
            headers: await customerHeaders(locationId: locationId)
        )
        let account: CustomerAccount = try await parseData(data: data)
        try Task.checkCancellation()

        return account

    }

    @concurrent
    func updateCustomerAccount(displayName: String) async throws -> CustomerAccount {

        let data = try await buildRequest(
            method: .patch,
            apiPath: .init(path: .customer("account")),
            parameters: ["display_name": displayName],
            headers: await customerHeaders()
        )
        let account: CustomerAccount = try await parseData(data: data)
        try Task.checkCancellation()

        return account

    }

    @concurrent
    func deleteCustomerAccount() async throws {

        _ = try await buildRequest(
            method: .delete,
            apiPath: .init(path: .customer("account")),
            headers: await customerHeaders()
        )
        try Task.checkCancellation()

    }

    @concurrent
    func getCustomerMembership(locationId: String) async throws -> CustomerLocationMembership {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .customer("locations/\(locationId)/membership")),
            headers: await customerHeaders(locationId: locationId)
        )
        let membership: CustomerLocationMembership = try await parseData(data: data)
        try Task.checkCancellation()

        guard membership.storeLocationId.lowercased() == locationId.lowercased() else {
            throw APIError.decodingError
        }

        return membership

    }

    @concurrent
    func joinCustomerMembership(locationId: String) async throws -> CustomerLocationMembership {

        let data = try await buildRequest(
            method: .post,
            apiPath: .init(path: .customer("locations/\(locationId)/membership")),
            headers: await customerHeaders(locationId: locationId)
        )
        let membership: CustomerLocationMembership = try await parseData(data: data)
        try Task.checkCancellation()

        guard membership.storeLocationId.lowercased() == locationId.lowercased() else {
            throw APIError.decodingError
        }

        return membership

    }

    @concurrent
    func getCustomerLoyaltyHistory(locationId: String, offset: Int) async throws -> CustomerPage<LoyaltyHistoryEntry> {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .customer("locations/\(locationId)/loyalty")),
            queryParameters: ["limit": "100", "offset": String(max(0, offset))],
            headers: await customerHeaders(locationId: locationId)
        )
        let response: CustomerPage<LoyaltyHistoryEntry> = try await parseData(data: data)
        try Task.checkCancellation()

        return response

    }

    func customerHeaders(locationId: String? = nil) -> [String: String] {

        var headers = ["x-app-key": BusinessConfig.appKey]

        if let locationId {
            headers["x-location-id"] = locationId
        }

        return headers

    }

}
