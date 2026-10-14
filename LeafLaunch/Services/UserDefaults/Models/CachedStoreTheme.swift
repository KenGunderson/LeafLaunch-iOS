//
//  CachedStoreTheme.swift
//  LeafLaunch
//

import Foundation

// Rune Theme contains ColorSource and UIFont and is not Codable. Cache the
// validated definition and reconstruct the actual Rune Theme before rendering.
nonisolated struct CachedStoreTheme: Codable, Sendable {

    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let businessId: String
    let appKey: String
    let bundleIdentifier: String
    let baseTheme: String
    let branding: StoreAppBranding

    @MainActor
    init(branding: StoreAppBranding, baseTheme: AvailableTheme) {
        self.schemaVersion = Self.currentSchemaVersion
        self.businessId = BusinessConfig.businessId
        self.appKey = BusinessConfig.appKey
        self.bundleIdentifier = BusinessConfig.bundleIdentifier
        self.baseTheme = baseTheme.rawValue
        self.branding = branding

    }

    @MainActor
    var matchesCurrentTarget: Bool {

        self.schemaVersion == Self.currentSchemaVersion
            && BusinessConfig.isConfigured
            && self.businessId == BusinessConfig.businessId
            && self.appKey == BusinessConfig.appKey
            && self.bundleIdentifier == BusinessConfig.bundleIdentifier
            && AvailableTheme(rawValue: self.baseTheme) != nil

    }

}
