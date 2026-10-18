import Foundation

nonisolated struct Product: Codable, Equatable, Hashable, Identifiable, Sendable {

    enum Status: String, Codable, Sendable {

        case draft = "DRAFT"
        case published = "PUBLISHED"
        case temporarilyUnavailable = "TEMPORARILY_UNAVAILABLE"
        case hidden = "HIDDEN"
        case archived = "ARCHIVED"

    }

    let id: String
    let storeProductId: String
    let storeLocationId: String
    let displayName: String
    let description: String?
    let status: Status
    let publishedAt: Date?
    let media: [ProductMedia]?
    let currencyCode: String
    let category: ProductCategory?
    let subcategory: ProductSubcategory?
    let attributes: [ProductAttribute]
    let variants: [ProductPricing]

    var activeImages: [ProductMedia] {

        return (self.media ?? [])
            .filter { $0.status == .active }
            .sorted {

                if $0.displayOrder == $1.displayOrder { return $0.id < $1.id }
                return $0.displayOrder < $1.displayOrder

            }

    }

    var isAvailable: Bool {
        self.status == .published && self.variants.contains { $0.availability == .available }
    }

    var minimumPrice: Decimal? {

        guard self.status == .published else { return nil }
        return self.variants.filter { $0.availability == .available }.compactMap(\.displayPrice).min()

    }

    private enum CodingKeys: String, CodingKey {

        case id
        case storeProductId = "store_product_id"
        case storeLocationId = "store_location_id"
        case displayName = "display_name"
        case description
        case status
        case publishedAt = "published_at"
        case media
        case currencyCode = "currency_code"
        case category
        case subcategory
        case attributes
        case variants

    }

}
