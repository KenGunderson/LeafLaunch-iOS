import Foundation

nonisolated enum ProductSort: String, Codable, CaseIterable, Equatable, Identifiable, Sendable {

    case featured
    case name
    case priceAscending = "price_ascending"
    case priceDescending = "price_descending"

    var id: String { self.rawValue }

    var title: String {

        switch self {
        case .featured: return String(localized: "Featured")
        case .name: return String(localized: "Name")
        case .priceAscending: return String(localized: "Price: Low To High")
        case .priceDescending: return String(localized: "Price: High To Low")
        }

    }

}
