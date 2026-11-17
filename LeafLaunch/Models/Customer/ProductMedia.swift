import Foundation

nonisolated struct ProductMedia: Codable, Equatable, Hashable, Identifiable, Sendable {

    enum Status: String, Codable, Sendable {

        case active = "ACTIVE"
        case retired = "RETIRED"

    }

    private enum CodingKeys: String, CodingKey {

        case id
        case storeProductId = "store_product_id"
        case url
        case width
        case height
        case altText = "alt_text"
        case displayOrder = "display_order"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"

    }

    let id: String
    let storeProductId: String
    let url: URL
    let width: Int?
    let height: Int?
    let altText: String?
    let displayOrder: Int
    let status: Status
    let createdAt: Date?
    let updatedAt: Date?

}
