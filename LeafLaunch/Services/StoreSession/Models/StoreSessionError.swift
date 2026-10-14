import Foundation

enum StoreSessionError: LocalizedError {

    case invalidLocation

    var errorDescription: String? {
        return String(localized: "This location is no longer available for this business.")
    }

}
