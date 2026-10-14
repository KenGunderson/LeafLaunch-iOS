import Foundation

nonisolated struct ProductAttribute: Codable, Equatable, Hashable, Identifiable, Sendable {

    enum ValueType: String, Codable, Sendable {

        case text = "TEXT"
        case integer = "INTEGER"
        case decimal = "DECIMAL"
        case boolean = "BOOLEAN"
        case singleSelect = "SINGLE_SELECT"
        case multiSelect = "MULTI_SELECT"
        case date = "DATE"
        case measurement = "MEASUREMENT"

    }

    let id: String
    let name: String
    let valueType: ValueType
    let value: ProductAttributeValue
    let unit: String?

    var displayValue: String {

        if case .measurement = self.value {
            return self.value.displayValue
        }

        return [self.value.displayValue, self.unit].compactMap { $0 }.joined(separator: " ")

    }

    private enum CodingKeys: String, CodingKey {

        case id
        case name
        case valueType = "value_type"
        case value
        case unit

    }

}
