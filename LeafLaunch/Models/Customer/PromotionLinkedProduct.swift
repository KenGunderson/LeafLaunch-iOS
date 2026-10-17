import Foundation

nonisolated struct PromotionLinkedProduct: Codable, Hashable, Identifiable, Sendable {

    let id: String
    let displayName: String
    let locationProductListingId: String?

    private enum CodingKeys: String, CodingKey {

        case id
        case displayName = "display_name"
        case locationProductListingId = "location_product_listing_id"

    }

}
