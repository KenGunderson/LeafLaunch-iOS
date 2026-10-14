import Foundation

nonisolated struct LoyaltyHistoryEntry: Codable, Identifiable, Sendable {

    enum EntryType: String, Codable, Sendable {

        case award = "AWARD"
        case redemption = "REDEMPTION"
        case correction = "CORRECTION"
        case reversal = "REVERSAL"

    }

    let id: String
    let entryType: EntryType
    let pointsDelta: String
    let customerReason: String
    let rewardTitleSnapshot: String?
    let createdAt: Date

    private enum CodingKeys: String, CodingKey {

        case id
        case entryType = "entry_type"
        case pointsDelta = "points_delta"
        case customerReason = "customer_reason"
        case rewardTitleSnapshot = "reward_title_snapshot"
        case createdAt = "created_at"

    }

}
