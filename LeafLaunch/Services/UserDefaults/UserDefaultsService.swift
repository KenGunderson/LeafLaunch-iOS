//
//  UserDefaultsService.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import Combine

// NOTES: -
/// If we want to use the app group we have set up to pass data to other extensions.
/// we can use this; notice the store being passed into the group
//@AppStorage(Setting.SomeSetting.rawValue, store: UserDefaults(suiteName: "group.com.gentlepath.app")) private(set) var someSettings: String? {
//    didSet {
//        WidgetCenter.shared.reloadAllTimelines()
//    }
//}

final class UserDefaultsService: UserDefaultsServiceProtocol {

    private let style: any StyleProtocol
    private let defaults = UserDefaults.standard
    
    internal let loggerName: String = "USER_DEFAULTS_SERVICE"
    internal let loggerEmoji: String = "🔐"
    
    @AppStorage(Setting.theme.rawValue) private(set) var theme: AvailableTheme = .light {
        didSet {
            self.themePublisher.send(self.theme)
        }
    }
    
    @AppStorage(Setting.didRateMyAppAlertShow.rawValue) private(set) var didRateMyAppAlertShow: Bool = false {
        didSet {
            self.didRateMyAppAlertShowPublisher.send(self.didRateMyAppAlertShow)
        }
    }
    
    @AppStorage(Setting.securityPinsDictionaryData.rawValue) private(set) var securityPinsDictionaryData: Data? {
        didSet {
            self.securityPinsDictionaryDataPublisher.send(self.securityPinsDictionaryData)
        }
    }
    
    @AppStorage(Setting.shouldHideScreenshots.rawValue) private(set) var shouldHideScreenshots: Bool = false {
        didSet {
            self.shouldHideScreenshotsPublisher.send(self.shouldHideScreenshots)
        }
    }
    
    var themePublisher = PassthroughSubject<AvailableTheme, Never>()
    var didRateMyAppAlertShowPublisher = PassthroughSubject<Bool, Never>()
    var securityPinsDictionaryDataPublisher = PassthroughSubject<Data?, Never>()
    var shouldHideScreenshotsPublisher = PassthroughSubject<Bool, Never>()
    let favoriteProductIdsPublisher = CurrentValueSubject<Set<String>, Never>([])

    var lastSelectedLocationId: String? {
        self.defaults.string(forKey: customerKey(.lastSelectedLocationId))
    }

    var guestIdentityId: String {

        let key = customerKey(.guestIdentityId)

        if let identity = self.defaults.string(forKey: key),
           identity.hasPrefix("guest:"),
           UUID(uuidString: String(identity.dropFirst(6))) != nil {
            return identity
        }

        let identity = "guest:\(UUID().uuidString)"
        self.defaults.set(identity, forKey: key)
        return identity

    }

    var ageVerificationApprovals: [String: [String]] {

        let key = customerKey(.ageVerificationApprovals)

        guard let data = self.defaults.data(forKey: key) else { return [:] }
        guard let approvals = try? JSONDecoder().decode([String: [String]].self, from: data) else {

            self.defaults.removeObject(forKey: key)
            return [:]

        }

        return approvals

    }

    private var ageVerificationApprovalMetadata: [String: [String: AgeVerificationApproval]] {

        let key = customerKey(.ageVerificationApprovalMetadata)

        guard let data = self.defaults.data(forKey: key) else { return [:] }
        guard let metadata = try? JSONDecoder().decode([String: [String: AgeVerificationApproval]].self, from: data) else {

            self.defaults.removeObject(forKey: key)
            return [:]

        }

        return metadata

    }

    var favoriteProductIds: Set<String> {

        let identifiers = self.defaults.stringArray(forKey: customerKey(.favoriteProductIds)) ?? []
        return Set(identifiers.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })

    }
    
    init(style: any StyleProtocol) {

        self.style = style
        
        self.logInit()
        restoreCachedStoreTheme()
        
        self.themePublisher.send(self.theme)
        self.didRateMyAppAlertShowPublisher.send(self.didRateMyAppAlertShow)
        self.securityPinsDictionaryDataPublisher.send(self.securityPinsDictionaryData)
        self.shouldHideScreenshotsPublisher.send(self.shouldHideScreenshots)
        self.favoriteProductIdsPublisher.send(self.favoriteProductIds)
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func set(theme: AvailableTheme) {
        
        let cachedBranding = loadCachedStoreTheme()?.branding
        self.theme = theme

        if let cachedBranding {
            applyStoreTheme(branding: cachedBranding)
        } else {
            self.style.updateTheme(self.theme.theme())
        }
        
    }
    
    func set(didRateMyAppAlertShow: Bool) {
        self.didRateMyAppAlertShow = didRateMyAppAlertShow
    }
    
    func set(securityPin: String?, businessId: String) {
        
        let key = self.securityPinsDictionaryData
        
        if var dict = try? JSONSerialization.jsonObject(with: key ?? Data(), options: []) as? [String: String?] {
            
            dict[businessId] = securityPin
            
            if let data = try? JSONEncoder().encode(dict) {
                self.securityPinsDictionaryData = data
            }
            
        } else {
            
            var dict = [String: String?]()
            dict[businessId] = securityPin
            
            if let data = try? JSONEncoder().encode(dict) {
                self.securityPinsDictionaryData = data
            }
            
        }
        
    }
    
    func set(shouldHideScreenshots: Bool) {
        self.shouldHideScreenshots = shouldHideScreenshots
    }
    
    func resetDevFlags() {
        
        self.set(didRateMyAppAlertShow: false)
        self.set(shouldHideScreenshots: false)
        
    }
    
    func getSecurityPinForBusinessId(_ businessId: String) -> String? {
        
        let key = self.securityPinsDictionaryData
        
        if let dict = try? JSONSerialization.jsonObject(with: key ?? Data(), options: []) as? [String: String?] {
            return dict[businessId] ?? nil
        }
        
        return nil
        
    }

    @discardableResult
    func restoreCachedStoreTheme() -> Bool {

        guard let cachedTheme = loadCachedStoreTheme(),
              let baseTheme = AvailableTheme(rawValue: cachedTheme.baseTheme),
              let storeTheme = StoreThemeBuilder.makeTheme(branding: cachedTheme.branding, baseTheme: baseTheme) else {

            self.defaults.removeObject(forKey: customerKey(.cachedStoreTheme))
            self.style.updateTheme(self.theme.theme())
            return false

        }

        self.style.updateTheme(storeTheme)
        return true

    }

    @discardableResult
    func applyStoreTheme(branding: StoreAppBranding?) -> Bool {

        let key = customerKey(.cachedStoreTheme)

        guard let branding else {

            self.defaults.removeObject(forKey: key)
            self.style.updateTheme(self.theme.theme())
            return true

        }

        guard BusinessConfig.isConfigured,
              let cachedTheme = CachedStoreTheme(branding: branding, baseTheme: self.theme),
              let storeTheme = StoreThemeBuilder.makeTheme(branding: cachedTheme.branding, baseTheme: self.theme),
              let encodedTheme = try? JSONEncoder().encode(cachedTheme) else {

            self.defaults.removeObject(forKey: key)
            self.style.updateTheme(self.theme.theme())
            return false

        }

        self.defaults.set(encodedTheme, forKey: key)
        self.style.updateTheme(storeTheme)
        return true

    }

    func set(lastSelectedLocationId: String?) {

        let key = customerKey(.lastSelectedLocationId)
        let locationId = lastSelectedLocationId?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let locationId, !locationId.isEmpty else {

            self.defaults.removeObject(forKey: key)
            return

        }

        self.defaults.set(locationId, forKey: key)

    }

    func hasApprovedAge(userId: String, state: String, policy: EffectiveAgePolicy) -> Bool {

        let approvedState = normalizedState(state)
        guard !userId.isEmpty,
              policy.isValid,
              approvedState == normalizedState(policy.approvalState(businessId: BusinessConfig.businessId)),
              self.ageVerificationApprovals[userId]?.contains(approvedState) == true,
              let metadata = self.ageVerificationApprovalMetadata[userId]?[approvedState] else { return false }

        return metadata.approves(policy: policy)

    }

    func approveAge(userId: String, state: String, policy: EffectiveAgePolicy) {

        let approvedState = normalizedState(state)
        guard !userId.isEmpty,
              policy.isValid,
              policy.required,
              approvedState == normalizedState(policy.approvalState(businessId: BusinessConfig.businessId)) else { return }

        var approvals = self.ageVerificationApprovals
        var approvedStates = Set(approvals[userId] ?? [])
        approvedStates.insert(approvedState)
        approvals[userId] = approvedStates.sorted()

        var metadata = self.ageVerificationApprovalMetadata
        var userMetadata = metadata[userId] ?? [:]
        userMetadata[approvedState] = AgeVerificationApproval(policy: policy)
        metadata[userId] = userMetadata

        guard let approvalData = try? JSONEncoder().encode(approvals),
              let metadataData = try? JSONEncoder().encode(metadata) else { return }

        self.defaults.set(metadataData, forKey: customerKey(.ageVerificationApprovalMetadata))
        self.defaults.set(approvalData, forKey: customerKey(.ageVerificationApprovals))

    }

    func setFavorite(productId: String, isFavorite: Bool) {

        let identifier = productId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !identifier.isEmpty else { return }

        var favoriteIds = self.favoriteProductIds

        if isFavorite {
            favoriteIds.insert(identifier)
        } else {
            favoriteIds.remove(identifier)
        }

        self.defaults.set(favoriteIds.sorted(), forKey: customerKey(.favoriteProductIds))
        self.favoriteProductIdsPublisher.send(favoriteIds)

    }

    private func loadCachedStoreTheme() -> CachedStoreTheme? {

        let key = customerKey(.cachedStoreTheme)

        guard let data = self.defaults.data(forKey: key) else { return nil }
        guard let cachedTheme = try? JSONDecoder().decode(CachedStoreTheme.self, from: data),
              cachedTheme.matchesCurrentTarget,
              let baseTheme = AvailableTheme(rawValue: cachedTheme.baseTheme),
              let currentTheme = CachedStoreTheme(branding: cachedTheme.branding, baseTheme: baseTheme) else {

            self.defaults.removeObject(forKey: key)
            return nil

        }

        // Version 1 stored only colors/fonts/media. Resolve the established radius
        // defaults once and persist the complete version 2 definition synchronously.
        if cachedTheme.schemaVersion != CachedStoreTheme.currentSchemaVersion,
           let migratedData = try? JSONEncoder().encode(currentTheme) {
            self.defaults.set(migratedData, forKey: key)
        }

        return currentTheme

    }

    private func customerKey(_ setting: Setting) -> String {
        "LeafLaunch.Customer.\(BusinessConfig.bundleIdentifier).\(BusinessConfig.businessId).\(BusinessConfig.appKey).\(setting.rawValue)"
    }

    private func normalizedState(_ state: String) -> String {

        state.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    }
    
    @MainActor
    func logout() async {

        // Customer exploration preferences remain available after sign-out.
        // Approvals stay keyed by identity; guest approval never signs in a user.
        self.securityPinsDictionaryData = nil
        set(shouldHideScreenshots: false)

    }
    
}
