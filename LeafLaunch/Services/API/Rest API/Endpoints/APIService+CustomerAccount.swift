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

        guard await account.storeId == BusinessConfig.businessId else { throw APIError.decodingError }
        return account

    }

    @concurrent
    func registerCustomerAccount(storeId: String, displayName: String) async throws -> CustomerAccount {

        let data = try await buildRequest(
            method: .post,
            apiPath: .init(path: .customer("account")),
            parameters: ["store_id": storeId, "display_name": displayName],
            headers: await customerHeaders()
        )
        let account: CustomerAccount = try await parseData(data: data)
        try Task.checkCancellation()

        guard await account.storeId == BusinessConfig.businessId else { throw APIError.decodingError }
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

        guard await account.storeId == BusinessConfig.businessId else { throw APIError.decodingError }
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

    @concurrent
    func getCustomerAgeGateAcceptance(locationId: String) async throws -> AgeGateAcceptance? {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .customer("age-gate")),
            queryParameters: ["location_id": locationId],
            headers: await customerHeaders(locationId: locationId)
        )
        let acceptance: AgeGateAcceptance? = try await parseData(data: data)
        try Task.checkCancellation()

        return acceptance

    }

    @concurrent
    func acceptCustomerAgeGate(locationId: String, policy: EffectiveAgePolicy) async throws -> AgeGateAcceptance {

        guard policy.isValid else { throw APIError.decodingError }

        let input = AgeGateAcceptanceInput(
            minimumAge: policy.minimumAge,
            gateVersion: policy.gateVersion,
            locationId: locationId,
            accepted: true
        )
        let data = try await buildRequest(
            method: .put,
            apiPath: .init(path: .customer("age-gate")),
            parameters: [
                "minimum_age": input.minimumAge,
                "gate_version": input.gateVersion,
                "location_id": input.locationId,
                "accepted": input.accepted
            ],
            headers: await customerHeaders(locationId: locationId)
        )
        let acceptance: AgeGateAcceptance = try await parseData(data: data)
        try Task.checkCancellation()

        return acceptance

    }

    func customerHeaders(locationId: String? = nil) -> [String: String] {

        var headers = ["x-app-key": BusinessConfig.appKey]

        if let locationId {
            headers["x-location-id"] = locationId
        }

        return headers

    }

}
