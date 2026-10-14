import Foundation

nonisolated struct ProductCategory: Codable, Equatable, Hashable, Identifiable, Sendable {

    enum Status: String, Codable, Sendable {

        case active = "ACTIVE"
        case retired = "RETIRED"

    }

    let id: String
    let revision: Int
    let subcategories: [ProductSubcategory]
    let pricingPresets: [CategoryPricingPreset]
    let attributeIds: [String]
    let name: String
    let imageObjectKey: String?
    let imageMimeType: String?
    let status: Status
    let displayOrder: Int
    let createdAt: Date?
    let updatedAt: Date?

    private enum CodingKeys: String, CodingKey {

        case id
        case revision
        case subcategories
        case pricingPresets = "pricing_presets"
        case attributeIds = "attribute_ids"
        case name
        case imageObjectKey = "image_object_key"
        case imageMimeType = "image_mime_type"
        case status
        case displayOrder = "display_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"

    }

}
