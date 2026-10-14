import Foundation

nonisolated struct ProductMedia: Codable, Equatable, Hashable, Identifiable, Sendable {

    enum Status: String, Codable, Sendable {

        case active = "ACTIVE"
        case retired = "RETIRED"

    }

    let id: String
    let storeProductId: String
    let objectKey: String
    let mimeType: String
    let width: Int?
    let height: Int?
    let altText: String?
    let displayOrder: Int
    let status: Status
    let createdAt: Date?
    let updatedAt: Date?

    private enum CodingKeys: String, CodingKey {

        case id
        case storeProductId = "store_product_id"
        case objectKey = "object_key"
        case mimeType = "mime_type"
        case width
        case height
        case altText = "alt_text"
        case displayOrder = "display_order"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"

    }

}
