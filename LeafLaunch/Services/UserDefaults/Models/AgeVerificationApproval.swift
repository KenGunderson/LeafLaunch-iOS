import Foundation

// Keep policy evidence beside the requested [userId: [state]] approval dictionary.
// Legacy state-only approvals intentionally require a fresh attestation.
nonisolated struct AgeVerificationApproval: Codable, Sendable {

    let countryCode: String?
    let region: String?
    let minimumAge: Int
    let gateVersion: Int
    let approvalRevision: Int

    init(policy: EffectiveAgePolicy) {

        self.countryCode = policy.canonicalCountryCode
        self.region = policy.canonicalRegion
        self.minimumAge = policy.minimumAge
        self.gateVersion = policy.gateVersion
        self.approvalRevision = policy.approvalRevision

    }

    func approves(policy: EffectiveAgePolicy) -> Bool {

        guard policy.isValid,
              (1...100).contains(self.minimumAge),
              self.gateVersion > 0,
              self.approvalRevision > 0 else { return false }

        let matchesCountry = self.countryCode == policy.canonicalCountryCode
        guard matchesCountry else { return false }

        let matchesRegion = self.region == policy.canonicalRegion
        guard matchesRegion else { return false }

        let coversMinimumAge = self.minimumAge >= policy.minimumAge
        var coversApprovalRevision: Bool { self.approvalRevision >= policy.approvalRevision }
        return coversMinimumAge && coversApprovalRevision

    }

}
