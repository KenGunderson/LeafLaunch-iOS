import Foundation

nonisolated struct CustomerPage<Value: Codable & Sendable>: Codable, Sendable {

    let data: [Value]
    let page: CustomerPageMetadata

}
