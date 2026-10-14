//
//  MockUserDefaultsService+Customer.swift
//  LeafLaunch
//

import Foundation

extension MockUserDefaultsService {

    @discardableResult
    func restoreCachedStoreTheme() -> Bool {

        guard let branding = self.cachedStoreBranding else {

            self.customerTheme = self.theme.theme()
            return false

        }

        return applyStoreTheme(branding: branding)

    }

    @discardableResult
    func applyStoreTheme(branding: StoreAppBranding?) -> Bool {

        guard let branding else {

            self.cachedStoreBranding = nil
            self.customerTheme = self.theme.theme()
            return true

        }

        guard let storeTheme = StoreThemeBuilder.makeTheme(branding: branding, baseTheme: self.theme) else {

            self.cachedStoreBranding = nil
            self.customerTheme = self.theme.theme()
            return false

        }

        self.cachedStoreBranding = branding
        self.customerTheme = storeTheme
        return true

    }

    func set(lastSelectedLocationId: String?) {

        let locationId = lastSelectedLocationId?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lastSelectedLocationId = locationId?.isEmpty == false ? locationId : nil

    }

    func hasApprovedAge(userId: String, state: String, policy: EffectiveAgePolicy) -> Bool {

        let approvedState = normalizedCustomerState(state)
        guard !userId.isEmpty,
              policy.isValid,
              approvedState == normalizedCustomerState(policy.approvalState(businessId: BusinessConfig.businessId)),
              self.ageVerificationApprovals[userId]?.contains(approvedState) == true,
              let metadata = self.ageVerificationApprovalMetadata[userId]?[approvedState] else { return false }

        return metadata.approves(policy: policy)

    }

    func approveAge(userId: String, state: String, policy: EffectiveAgePolicy) {

        let approvedState = normalizedCustomerState(state)
        guard !userId.isEmpty,
              policy.isValid,
              policy.required,
              approvedState == normalizedCustomerState(policy.approvalState(businessId: BusinessConfig.businessId)) else { return }

        var approvedStates = Set(self.ageVerificationApprovals[userId] ?? [])
        approvedStates.insert(approvedState)
        self.ageVerificationApprovals[userId] = approvedStates.sorted()

        var metadata = self.ageVerificationApprovalMetadata[userId] ?? [:]
        metadata[approvedState] = AgeVerificationApproval(policy: policy)
        self.ageVerificationApprovalMetadata[userId] = metadata

    }

    func setFavorite(productId: String, isFavorite: Bool) {

        let identifier = productId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !identifier.isEmpty else { return }

        if isFavorite {
            self.favoriteProductIds.insert(identifier)
        } else {
            self.favoriteProductIds.remove(identifier)
        }

        self.favoriteProductIdsPublisher.send(self.favoriteProductIds)

    }

    private func normalizedCustomerState(_ state: String) -> String {

        let value = state.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return Constants.USState.allCases.first { $0.description.uppercased() == value }?.rawValue ?? value

    }

}
