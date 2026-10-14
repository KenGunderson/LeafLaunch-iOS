import Foundation

nonisolated struct ProductPricing: Codable, Equatable, Hashable, Identifiable, Sendable {

    enum Availability: String, Codable, Sendable {

        case available = "AVAILABLE"
        case temporarilyUnavailable = "TEMPORARILY_UNAVAILABLE"
        case hidden = "HIDDEN"

    }

    let id: String
    let productVariantId: String
    let displayPrice: Decimal?
    let availability: Availability
    let name: String
    let baseDisplayPrice: Decimal?
    let promotionId: String?

    private enum CodingKeys: String, CodingKey {

        case id
        case productVariantId = "product_variant_id"
        case displayPrice = "display_price"
        case availability
        case name
        case baseDisplayPrice = "base_display_price"
        case promotionId = "promotion_id"

    }

}
