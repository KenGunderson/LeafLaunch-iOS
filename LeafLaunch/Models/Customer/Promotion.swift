import Foundation

nonisolated struct Promotion: Codable, Identifiable, Sendable {

    enum Kind: String, Codable, Sendable {

        case general = "GENERAL"
        case sale = "SALE"
        case newProduct = "NEW_PRODUCT"
        case link = "LINK"

    }

    let id: String
    let storeId: String
    let image: MarketingImage?
    let url: String?
    let linkedProducts: [PromotionLinkedProduct]
    let linkedProductIds: [String]
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

    private enum CodingKeys: String, CodingKey {

        case id
        case storeId = "store_id"
        case image
        case url
        case linkedProducts = "linked_products"
        case linkedProductIds = "linked_product_ids"
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

    }

}
