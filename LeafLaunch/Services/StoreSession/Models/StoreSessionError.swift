import Foundation

enum StoreSessionError: LocalizedError {

    case invalidLocation
    case invalidConfiguration
    case invalidAgePolicy

    var errorDescription: String? {
        switch self {
        case .invalidLocation:
            return String(localized: "This location is no longer available for this business.")
        case .invalidConfiguration:
            return String(localized: "This app configuration belongs to another business.")
        case .invalidAgePolicy:
            return String(localized: "The age policy for this location could not be verified. Refresh the store to continue.")
        }
    }

}
