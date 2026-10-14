import Foundation

// Customer-safe Store details supplied by the public app bootstrap.
nonisolated struct PublicStore: Codable, Equatable, Identifiable, Sendable {

    let id: String
    let name: String
    let legalName: String?
    let supportEmail: String?
    let supportPhone: String?
    let websiteURL: URL?

    private enum CodingKeys: String, CodingKey {

        case id
        case name
        case legalName = "legal_name"
        case supportEmail = "support_email"
        case supportPhone = "support_phone"
        case websiteURL = "website_url"

    }

}
