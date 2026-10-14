import Foundation

enum ProductSort: String, CaseIterable, Identifiable {

    case featured
    case name
    case priceAscending
    case priceDescending

    var id: String { self.rawValue }

    var title: String {

        switch self {
        case .featured: return String(localized: "Featured")
        case .name: return String(localized: "Name")
        case .priceAscending: return String(localized: "Price: Low to High")
        case .priceDescending: return String(localized: "Price: High to Low")
        }

    }

    func sorted(_ products: [Product]) -> [Product] {

        guard self != .featured else { return products }

        return products.sorted { lhs, rhs in

            if self == .priceAscending || self == .priceDescending {

                switch (lhs.minimumPrice, rhs.minimumPrice) {
                case (nil, nil): break
                case (nil, _): return false
                case (_, nil): return true
                case (let lhsPrice?, let rhsPrice?) where lhsPrice != rhsPrice:
                    return self == .priceAscending ? lhsPrice < rhsPrice : lhsPrice > rhsPrice
                default: break
                }

            }

            let order = lhs.displayName.localizedStandardCompare(rhs.displayName)
            return order == .orderedSame ? lhs.id < rhs.id : order == .orderedAscending

        }

    }

}
