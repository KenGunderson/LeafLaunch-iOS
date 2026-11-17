import Foundation

nonisolated struct ScheduleException: Codable, Identifiable, Sendable {

    private enum CodingKeys: String, CodingKey {

        case id
        case storeLocationId = "store_location_id"
        case localDate = "local_date"
        case label
        case sequence
        case opensAt = "opens_at"
        case closesAt = "closes_at"
        case closed
        case createdAt = "created_at"
        case updatedAt = "updated_at"

    }

    let id: String
    let storeLocationId: String
    let localDate: String
    let label: String?
    let sequence: Int
    let opensAt: String?
    let closesAt: String?
    let closed: Bool
    let createdAt: Date
    let updatedAt: Date

}
