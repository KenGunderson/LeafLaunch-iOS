import Foundation

nonisolated struct AgeGateAcceptanceInput: Encodable, Sendable {

    let locationId: String
    let minimumAge: Int
    let gateVersion: Int
    let accepted: Bool

    init(minimumAge: Int,
         gateVersion: Int,
         locationId: String,
         accepted: Bool = true) {

        self.locationId = locationId
        self.minimumAge = minimumAge
        self.gateVersion = gateVersion
        self.accepted = accepted

    }

    private enum CodingKeys: String, CodingKey {

        case locationId = "location_id"
        case minimumAge = "minimum_age"
        case gateVersion = "gate_version"
        case accepted

    }

}
