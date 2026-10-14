import Foundation

enum CustomerScreenEvent {

    case locations(businessId: String)
    case ageVerification(locationId: String)
    case store(locationId: String)
    case overview(locationId: String)
    case shop(locationId: String)
    case favorites(locationId: String)
    case product(locationId: String, productId: String)
    case account(locationId: String)

    var screenName: String {

        switch self {
        case .locations: return "customer_locations"
        case .ageVerification: return "customer_age_verification"
        case .store: return "customer_store"
        case .overview: return "customer_store_overview"
        case .shop: return "customer_shop"
        case .favorites: return "customer_favorites"
        case .product: return "customer_product"
        case .account: return "customer_account"
        }

    }

    var properties: [String: Any] {

        switch self {
        case .locations(let businessId): return ["business_id": businessId]

        case .ageVerification(let locationId),
             .store(let locationId),
             .overview(let locationId),
             .shop(let locationId),
             .favorites(let locationId),
             .account(let locationId):
            return ["business_id": BusinessConfig.businessId, "location_id": locationId]

        case .product(let locationId, let productId):
            return ["business_id": BusinessConfig.businessId, "location_id": locationId, "product_id": productId]
        }

    }

}
