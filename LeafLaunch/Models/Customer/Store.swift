import Foundation

nonisolated struct Store: Codable, Identifiable, Sendable {

    enum Status: String, Codable, Sendable {

        case draft = "DRAFT"
        case onboarding = "ONBOARDING"
        case active = "ACTIVE"
        case gracePeriod = "GRACE_PERIOD"
        case suspended = "SUSPENDED"
        case canceled = "CANCELED"
        case archived = "ARCHIVED"

    }

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let name: String
    let legalName: String?
    let categoryIds: [String]
    let createdByAccountId: String
    let assignedAdminAccountId: String?
    let stripeCustomerId: String?
    let status: Status
    let statusEffectiveAt: Date?
    let archivedAt: Date?
    let locations: CustomerPage<StoreLocation>?
    let appConfiguration: StoreAppConfiguration?
    let promotions: CustomerPage<Promotion>?
    let events: CustomerPage<StoreEvent>?

    private enum CodingKeys: String, CodingKey {

        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case name
        case legalName = "legal_name"
        case categoryIds = "category_ids"
        case createdByAccountId = "created_by_account_id"
        case assignedAdminAccountId = "assigned_admin_account_id"
        case stripeCustomerId = "stripe_customer_id"
        case status
        case statusEffectiveAt = "status_effective_at"
        case archivedAt = "archived_at"
        case locations
        case appConfiguration = "app_configuration"
        case promotions
        case events

    }

}
