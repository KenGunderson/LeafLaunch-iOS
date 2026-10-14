import Foundation

nonisolated struct PromotionVariantTarget: Codable, Identifiable, Sendable {

    enum DiscountType: String, Codable, Sendable {

        case percent = "PERCENT"
        case fixed = "FIXED"
        case override = "OVERRIDE"

    }

    let id: String
    let promotionId: String
    let locationVariantListingId: String
    let discountType: DiscountType
    let discountValue: Decimal?
    let overridePrice: Decimal?
    let basePriceSnapshot: Decimal?
    let displayNameSnapshot: String?
    let effectiveStartsAt: Date?
    let effectiveEndsAt: Date?
    let effective: Bool
    let createdAt: Date
    let updatedAt: Date

    private enum CodingKeys: String, CodingKey {

        case id
        case promotionId = "promotion_id"
        case locationVariantListingId = "location_variant_listing_id"
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case overridePrice = "override_price"
        case basePriceSnapshot = "base_price_snapshot"
        case displayNameSnapshot = "display_name_snapshot"
        case effectiveStartsAt = "effective_starts_at"
        case effectiveEndsAt = "effective_ends_at"
        case effective
        case createdAt = "created_at"
        case updatedAt = "updated_at"

    }

}
