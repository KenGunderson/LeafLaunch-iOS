import Foundation

extension APIService {

    @concurrent
    func getCustomerBootstrap(appKey: String) async throws -> CustomerBootstrap {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .customerPublic("apps/\(appKey)/bootstrap")),
            queryParameters: ["platform": "IOS", "version": await Self.appVersion],
            requiresAuthentication: false
        )
        let bootstrap: CustomerBootstrap = try await parseData(data: data)
        try Task.checkCancellation()

        guard bootstrap.appKey.lowercased() == appKey.lowercased() else {
            throw APIError.decodingError
        }

        return bootstrap

    }

    @concurrent
    func getCustomerLocation(businessId: String, locationId: String) async throws -> CustomerLocationDetails {

        let data = try await buildRequest(
            method: .get,
            apiPath: .init(path: .customerPublic("locations/\(locationId)/hours")),
            requiresAuthentication: false
        )
        let details: CustomerLocationDetails = try await parseData(data: data)
        try Task.checkCancellation()

        guard details.location.id.lowercased() == locationId.lowercased(),
              details.location.storeId.lowercased() == businessId.lowercased(),
              details.location.isAvailable else {
            throw APIError.serverError(statusCode: 404, errorMessage: "This location is unavailable for this business.")
        }

        return details

    }

}
