import Foundation

nonisolated struct CustomerAccount: Codable, Equatable, Identifiable, Sendable {

    enum Status: String, Codable, Sendable {

        case active = "ACTIVE"
        case suspended = "SUSPENDED"
        case banned = "BANNED"
        case anonymized = "ANONYMIZED"

    }

    let id: String
    let accountId: String
    let storeId: String
    let storeName: String
    let membershipCode: String
    let cachedPointsBalance: String
    let displayName: String
    let status: Status
    let anonymizedAt: Date?
    let createdAt: Date
    let updatedAt: Date

    private enum CodingKeys: String, CodingKey {

        case id
        case accountId = "account_id"
        case storeId = "store_id"
        case storeName = "store_name"
        case membershipCode = "membership_code"
        case cachedPointsBalance = "cached_points_balance"
        case displayName = "display_name"
        case status
        case anonymizedAt = "anonymized_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"

    }

}
