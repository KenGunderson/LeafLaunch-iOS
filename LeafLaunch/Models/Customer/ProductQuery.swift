import Foundation

nonisolated struct ProductQuery: Codable, Equatable, Sendable {

    var search: String = ""
    var categoryId: String?
    var subcategoryId: String?
    var sort: ProductSort = .featured
    var offset: Int = 0
    var limit: Int = 100

    var parameters: [String: String] {

        var parameters = [
            "sort": self.sort.rawValue,
            "offset": String(max(0, self.offset)),
            "limit": String(min(100, max(1, self.limit)))
        ]

        let search = self.search.trimmingCharacters(in: .whitespacesAndNewlines)

        if !search.isEmpty {
            parameters["query"] = String(search.prefix(200))
        }

        if let categoryId = self.categoryId {
            parameters["category_id"] = categoryId
        }

        if let subcategoryId = self.subcategoryId, self.categoryId != nil {
            parameters["subcategory_id"] = subcategoryId
        }

        return parameters

    }

}
