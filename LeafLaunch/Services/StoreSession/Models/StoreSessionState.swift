import Foundation

enum StoreSessionState: Equatable, Sendable {

    case loading
    case locations
    case ageVerification
    case store
    case unavailable
    case updateRequired
    case configurationRequired
    case failed

}
