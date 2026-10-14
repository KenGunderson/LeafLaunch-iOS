import Foundation

nonisolated struct MarketingImage: Codable, Sendable {

    let objectKey: String
    let mimeType: String
    let url: URL?

    private enum CodingKeys: String, CodingKey {

        case objectKey = "object_key"
        case mimeType = "mime_type"
        case url

    }

}
