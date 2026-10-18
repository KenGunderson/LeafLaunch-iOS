import Foundation

nonisolated enum LocationSelectionStep: Hashable, Sendable {

    case locationSelection
    case ageVerification(locationId: String)

}
