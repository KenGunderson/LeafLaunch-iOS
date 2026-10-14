import Foundation

nonisolated struct CustomerPageMetadata: Codable, Equatable, Sendable {

    let limit: Int
    let offset: Int
    let hasMore: Bool
    let nextOffset: Int?

}
