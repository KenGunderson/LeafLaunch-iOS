import Foundation

nonisolated struct CustomerLocationMembership: Codable, Identifiable, Sendable {

    enum Status: String, Codable, Sendable {

        case active = "ACTIVE"
        case left = "LEFT"
        case anonymized = "ANONYMIZED"

    }

    let id: String
    let loyaltyAccountId: String
    let customerAccountId: String
    let storeLocationId: String
    let membershipCode: String
    let status: Status
    let cachedPointsBalance: String
    let joinedAt: Date
    let leftAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let notificationPreference: CustomerNotificationPreference?
    let customerDisplayName: String?

    private enum CodingKeys: String, CodingKey {

        case id
        case loyaltyAccountId = "loyalty_account_id"
        case customerAccountId = "customer_account_id"
        case storeLocationId = "store_location_id"
        case membershipCode = "membership_code"
        case status
        case cachedPointsBalance = "cached_points_balance"
        case joinedAt = "joined_at"
        case leftAt = "left_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case notificationPreference = "notification_preference"
        case customerDisplayName = "customer_display_name"

    }

}
