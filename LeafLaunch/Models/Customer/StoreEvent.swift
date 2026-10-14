import Foundation

nonisolated struct StoreEvent: Codable, Identifiable, Sendable {

    let id: String
    let storeId: String
    let image: MarketingImage?
    let title: String
    let description: String?
    let status: ContentStatus
    let startsAt: Date?
    let endsAt: Date?
    let publishedAt: Date?
    let externalURL: URL?
    let createdAt: Date
    let updatedAt: Date
    let locations: [EventLocation]?

    private enum CodingKeys: String, CodingKey {

        case id
        case storeId = "store_id"
        case image
        case title
        case description
        case status
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case publishedAt = "published_at"
        case externalURL = "external_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case locations

    }

}
