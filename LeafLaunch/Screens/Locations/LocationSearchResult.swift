import CoreLocation

nonisolated struct LocationSearchResult: Sendable {

    let location: CLLocation
    let postalCode: String?

}
