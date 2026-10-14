import Foundation

nonisolated enum ContentStatus: String, Codable, Sendable {

    case draft = "DRAFT"
    case scheduled = "SCHEDULED"
    case active = "ACTIVE"
    case ended = "ENDED"
    case canceled = "CANCELED"
    case archived = "ARCHIVED"

}
