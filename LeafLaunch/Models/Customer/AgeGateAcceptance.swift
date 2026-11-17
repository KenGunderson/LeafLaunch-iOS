import Foundation

nonisolated struct AgeGateAcceptance: Codable, Identifiable, Sendable {

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

        guard policy.isValid,
              acceptedPolicy.isValid,
              UUID(uuidString: self.locationId) != nil else { return false }

        let matchesStore = self.storeId.lowercased() == businessId.lowercased()
        guard matchesStore else { return false }

        let matchesCustomer = self.customerAccountId.lowercased() == customerAccountId.lowercased()
        guard matchesCustomer else { return false }

        let matchesCountry = acceptedPolicy.canonicalCountryCode == policy.canonicalCountryCode
        guard matchesCountry else { return false }

        let matchesRegion = acceptedPolicy.canonicalRegion == policy.canonicalRegion
        guard matchesRegion else { return false }

        let coversMinimumAge = self.minimumAge >= policy.minimumAge
        var coversApprovalRevision: Bool { self.approvalRevision >= policy.approvalRevision }
        return coversMinimumAge && coversApprovalRevision

    }

}
