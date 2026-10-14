import Foundation

nonisolated struct BootstrapLocation: Codable, Equatable, Hashable, Identifiable, Sendable {

    let id: String
    let name: String
    let timezone: String?
    let currencyCode: String?
    let countryCode: String?
    let region: String?
    let agePolicy: EffectiveAgePolicy

    private enum CodingKeys: String, CodingKey {

        case id
        case name
        case timezone
        case currencyCode = "currency_code"
        case countryCode = "country_code"
        case region
        case agePolicy = "age_policy"

    }

}
