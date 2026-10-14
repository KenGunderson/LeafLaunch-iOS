import Foundation

nonisolated struct ProductSubcategory: Codable, Equatable, Hashable, Identifiable, Sendable {

    let id: String
    let name: String
    let categoryId: String?

    private enum CodingKeys: String, CodingKey {

        case id
        case name
        case categoryId = "category_id"

    }

}
