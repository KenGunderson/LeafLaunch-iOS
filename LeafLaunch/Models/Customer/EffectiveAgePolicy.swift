import Foundation

nonisolated struct EffectiveAgePolicy: Codable, Equatable, Hashable, Sendable {

    let required: Bool
    let minimumAge: Int
    let countryCode: String?
    let region: String?
    let gateVersion: Int
    let approvalRevision: Int

    var canonicalCountryCode: String? {
        self.countryCode?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    var canonicalRegion: String? {
        self.region?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    var isValid: Bool {

        let hasValidCountry = self.canonicalCountryCode.map {
            $0.range(of: "^[A-Z]{2}$", options: .regularExpression) != nil
        } ?? true
        let hasValidRegion = self.canonicalRegion.map { !$0.isEmpty && $0.count <= 100 } ?? true

        return (1...100).contains(self.minimumAge)
            && self.gateVersion > 0
            && self.approvalRevision > 0
            && hasValidCountry
            && hasValidRegion

    }

    func approvalState(businessId: String) -> String {

        guard let countryCode = self.canonicalCountryCode,
              let region = self.canonicalRegion,
              !countryCode.isEmpty,
              !region.isEmpty else {
            return "UNKNOWN:\(businessId.lowercased())"
        }

        return "\(countryCode):\(region)"

    }

    private enum CodingKeys: String, CodingKey {

        case required
        case minimumAge = "minimum_age"
        case countryCode = "country_code"
        case region
        case gateVersion = "gate_version"
        case approvalRevision = "approval_revision"

    }

}
