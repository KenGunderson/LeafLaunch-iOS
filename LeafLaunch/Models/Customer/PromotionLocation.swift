import Foundation

nonisolated struct PromotionLocation: Codable, Identifiable, Sendable {

    private enum CodingKeys: String, CodingKey {

        case id
        case promotionId = "promotion_id"
        case storeLocationId = "store_location_id"
        case timezone
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"

    }

    let id: String
    let promotionId: String
    let storeLocationId: String
    let timezone: String
    let startsAt: Date
    let endsAt: Date
    let createdAt: Date
    let updatedAt: Date

}
