import Foundation

nonisolated struct CustomerBootstrap: Codable, Equatable, Sendable {

    enum State: String, Codable, Sendable {

        case updateRequired = "update_required"
        case unavailable
        case available

    }

    let appKey: String
    let storeId: String
    let store: PublicStore
    let publicName: String
    let state: State
    let updateURL: URL?
    let branding: StoreAppBranding?
    let ageGateRequired: Bool
    let minimumAge: Int
    let ageGateVersion: Int
    let featureFlags: [String: Bool]?
    let locations: [BootstrapLocation]

    private enum CodingKeys: String, CodingKey {

        case appKey = "app_key"
        case storeId = "store_id"
        case store
        case publicName = "public_name"
        case state
        case updateURL = "update_url"
        case branding
        case ageGateRequired = "age_gate_required"
        case minimumAge = "minimum_age"
        case ageGateVersion = "age_gate_version"
        case featureFlags = "feature_flags"
        case locations

    }

}
