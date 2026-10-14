import Foundation

nonisolated struct PromotionLinkedProduct: Codable, Identifiable, Sendable {

    let id: String
    let storeLocationId: String
    let displayName: String

    private enum CodingKeys: String, CodingKey {

        case id
        case storeLocationId = "store_location_id"
        case displayName = "display_name"

    }

}
