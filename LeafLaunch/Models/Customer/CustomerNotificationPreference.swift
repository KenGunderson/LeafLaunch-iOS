import Foundation

nonisolated struct CustomerNotificationPreference: Codable, Identifiable, Sendable {

    let id: String
    let membershipId: String
    let appMasterEnabled: Bool
    let locationEnabled: Bool
    let createdAt: Date
    let updatedAt: Date

    private enum CodingKeys: String, CodingKey {

        case id
        case membershipId = "membership_id"
        case appMasterEnabled = "app_master_enabled"
        case locationEnabled = "location_enabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"

    }

}
