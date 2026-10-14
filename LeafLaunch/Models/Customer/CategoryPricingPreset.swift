import Foundation

nonisolated struct CategoryPricingPreset: Codable, Equatable, Hashable, Identifiable, Sendable {

    let id: String
    let label: String
    let unit: String?
    let quantity: Decimal?

}
