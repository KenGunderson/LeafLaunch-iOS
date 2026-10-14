import Foundation

nonisolated struct StoreAppConfiguration: Codable, Identifiable, Sendable {

    enum ReadinessStatus: String, Codable, Sendable {

        case needsStoreInfo = "NEEDS_STORE_INFO"
        case needsProducts = "NEEDS_PRODUCTS"
        case needsAppAssets = "NEEDS_APP_ASSETS"
        case appInReview = "APP_IN_REVIEW"
        case completed = "COMPLETED"

    }

    let id: String
    let revision: Int
    let createdAt: Date
    let updatedAt: Date
    let storeId: String
    let appKey: String
    let publicName: String
    let readinessStatus: ReadinessStatus
    let iosBundleId: String?
    let androidPackageName: String?
    let firebaseProjectId: String?
    let firebaseIosAppId: String?
    let firebaseAndroidAppId: String?
    let supportEmail: String?
    let supportPhone: String?
    let websiteURL: URL?
    let ageGateRequired: Bool
    let minimumAge: Int
    let ageGateVersion: Int
    let branding: StoreAppBranding?
    let iosMinimumVersion: String?
    let androidMinimumVersion: String?
    let iosUpdateURL: URL?
    let androidUpdateURL: URL?
    let featureFlags: [String: Bool]?

    private enum CodingKeys: String, CodingKey {

        case id
        case revision
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case storeId = "store_id"
        case appKey = "app_key"
        case publicName = "public_name"
        case readinessStatus = "readiness_status"
        case iosBundleId = "ios_bundle_id"
        case androidPackageName = "android_package_name"
        case firebaseProjectId = "firebase_project_id"
        case firebaseIosAppId = "firebase_ios_app_id"
        case firebaseAndroidAppId = "firebase_android_app_id"
        case supportEmail = "support_email"
        case supportPhone = "support_phone"
        case websiteURL = "website_url"
        case ageGateRequired = "age_gate_required"
        case minimumAge = "minimum_age"
        case ageGateVersion = "age_gate_version"
        case branding
        case iosMinimumVersion = "ios_minimum_version"
        case androidMinimumVersion = "android_minimum_version"
        case iosUpdateURL = "ios_update_url"
        case androidUpdateURL = "android_update_url"
        case featureFlags = "feature_flags"

    }

}
