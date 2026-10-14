import Foundation

nonisolated struct ProductAttributeMeasurement: Codable, Equatable, Hashable, Sendable {

    let amount: Decimal
    let unit: String

}
