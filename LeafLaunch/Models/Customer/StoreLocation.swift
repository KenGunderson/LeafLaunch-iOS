import Foundation

nonisolated struct StoreLocation: Codable, Identifiable, Sendable {

    enum Status: String, Codable, Sendable {

        case draft = "DRAFT"
        case pendingActivation = "PENDING_ACTIVATION"
        case active = "ACTIVE"
        case pendingArchive = "PENDING_ARCHIVE"
        case inactive = "INACTIVE"
        case archived = "ARCHIVED"

    }

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let storeId: String
    let name: String
    let status: Status
    let addressLine1: String?
    let addressLine2: String?
    let city: String?
    let region: String?
    let postalCode: String?
    let countryCode: String?
    let timezone: String?
    let currencyCode: String?
    let archiveEffectiveAt: Date?
    let hours: [StoreHours]?
    let scheduleExceptions: [ScheduleException]?

    var address: String {
        [self.addressLine1, self.addressLine2, self.city, self.region, self.postalCode, self.countryCode]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    var isAvailable: Bool {

        switch self.status {
        case .active:
            return true
        case .pendingArchive:
            return self.archiveEffectiveAt.map { $0 > Date() } ?? false
        default:
            return false
        }

    }

    private enum CodingKeys: String, CodingKey {

        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case storeId = "store_id"
        case name
        case status
        case addressLine1 = "address_line_1"
        case addressLine2 = "address_line_2"
        case city
        case region
        case postalCode = "postal_code"
        case countryCode = "country_code"
        case timezone
        case currencyCode = "currency_code"
        case archiveEffectiveAt = "archive_effective_at"
        case hours
        case scheduleExceptions = "schedule_exceptions"

    }

}
