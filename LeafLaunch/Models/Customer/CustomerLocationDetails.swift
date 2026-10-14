import Foundation

nonisolated struct CustomerLocationDetails: Codable, Sendable {

    let location: StoreLocation
    let openNow: Bool
    let localDate: String
    let mapsAddress: String

    private enum CodingKeys: String, CodingKey {

        case location
        case openNow = "open_now"
        case localDate = "local_date"
        case mapsAddress = "maps_address"

    }

}
