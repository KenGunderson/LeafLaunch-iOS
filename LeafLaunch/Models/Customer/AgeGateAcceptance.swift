import Foundation

nonisolated struct AgeGateAcceptance: Codable, Identifiable, Sendable {

    let id: String
    let customerAccountId: String
    let storeId: String
    let locationId: String
    let countryCode: String?
    let region: String?
    let minimumAge: Int
    let gateVersion: Int
    let approvalRevision: Int
    let acceptedAt: Date

    func applies(to policy: EffectiveAgePolicy,
                 businessId: String,
                 customerAccountId: String) -> Bool {

        let acceptedPolicy = EffectiveAgePolicy(
            required: true,
            minimumAge: self.minimumAge,
            countryCode: self.countryCode,
            region: self.region,
            gateVersion: self.gateVersion,
            approvalRevision: self.approvalRevision
        )

        return policy.isValid
            && acceptedPolicy.isValid
            && UUID(uuidString: self.locationId) != nil
            && self.storeId.lowercased() == businessId.lowercased()
            && self.customerAccountId.lowercased() == customerAccountId.lowercased()
            && acceptedPolicy.canonicalCountryCode == policy.canonicalCountryCode
            && acceptedPolicy.canonicalRegion == policy.canonicalRegion
            && self.minimumAge >= policy.minimumAge
            && self.approvalRevision >= policy.approvalRevision

    }

    private enum CodingKeys: String, CodingKey {

        case id
        case customerAccountId = "customer_account_id"
        case storeId = "store_id"
        case locationId = "location_id"
        case countryCode = "country_code"
        case region
        case minimumAge = "minimum_age"
        case gateVersion = "gate_version"
        case approvalRevision = "approval_revision"
        case acceptedAt = "accepted_at"

    }

}
