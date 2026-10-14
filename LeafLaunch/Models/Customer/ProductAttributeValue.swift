import Foundation

nonisolated enum ProductAttributeValue: Codable, Equatable, Hashable, Sendable {

    case text(String)
    case number(Decimal)
    case boolean(Bool)
    case selection([String])
    case measurement(ProductAttributeMeasurement)

    var displayValue: String {

        switch self {
        case .text(let value): return value
        case .number(let value): return NSDecimalNumber(decimal: value).stringValue
        case .boolean(let value): return value ? "Yes" : "No"
        case .selection(let values): return values.joined(separator: ", ")
        case .measurement(let value):
            return "\(NSDecimalNumber(decimal: value.amount).stringValue) \(value.unit)"
        }

    }

    init(from decoder: Decoder) throws {

        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .text(value)
        }
        else if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
        }
        else if let value = try? container.decode(Decimal.self) {
            self = .number(value)
        }
        else if let value = try? container.decode([String].self) {
            self = .selection(value)
        }
        else {
            self = .measurement(try container.decode(ProductAttributeMeasurement.self))
        }

    }

    func encode(to encoder: Encoder) throws {

        var container = encoder.singleValueContainer()

        switch self {
        case .text(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .boolean(let value): try container.encode(value)
        case .selection(let value): try container.encode(value)
        case .measurement(let value): try container.encode(value)
        }

    }

}
