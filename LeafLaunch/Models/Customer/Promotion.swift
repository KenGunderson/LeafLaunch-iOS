import Foundation

nonisolated struct Promotion: Codable, Identifiable, Sendable {

    enum Kind: String, Codable, Sendable {

        case informational = "INFORMATIONAL"
        case priceOverride = "PRICE_OVERRIDE"

    }

    let id: String
    let storeId: String
    let image: MarketingImage?
    let linkedProducts: [PromotionLinkedProduct]?
    let linkedProductListingIds: [String]?
    let title: String
    let description: String?
    let kind: Kind
    let status: ContentStatus
    let startsAt: Date?
    let endsAt: Date?
    let publishedAt: Date?
    let displayOrder: Int
    let createdAt: Date
    let updatedAt: Date
    let locations: [PromotionLocation]?
    let variantTargets: [PromotionVariantTarget]?

    private enum CodingKeys: String, CodingKey {

        case id
        case storeId = "store_id"
        case image
        case linkedProducts = "linked_products"
        case linkedProductListingIds = "linked_product_listing_ids"
        case title
        case description
        case kind
        case status
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case publishedAt = "published_at"
        case displayOrder = "display_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case locations
        case variantTargets = "variant_targets"

    }

}
