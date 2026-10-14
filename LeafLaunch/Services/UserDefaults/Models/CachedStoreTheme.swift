//
//  CachedStoreTheme.swift
//  LeafLaunch
//

import Foundation

// Rune Theme contains ColorSource and UIFont and is not Codable. Cache the
// validated definition and reconstruct the actual Rune Theme before rendering.
nonisolated struct CachedStoreTheme: Codable, Sendable {

    static let currentSchemaVersion = 2

    let schemaVersion: Int
    let businessId: String
    let appKey: String
    let bundleIdentifier: String
    let baseTheme: String
    let branding: StoreAppBranding

    @MainActor
    init?(branding: StoreAppBranding, baseTheme: AvailableTheme) {

        guard let definition = StoreThemeBuilder.validatedDefinition(branding: branding) else { return nil }

        self.schemaVersion = Self.currentSchemaVersion
        self.businessId = BusinessConfig.businessId
        self.appKey = BusinessConfig.appKey
        self.bundleIdentifier = BusinessConfig.bundleIdentifier
        self.baseTheme = baseTheme.rawValue
        self.branding = definition

    }

    @MainActor
    var matchesCurrentTarget: Bool {

        (self.schemaVersion == 1 || self.schemaVersion == Self.currentSchemaVersion)
            && BusinessConfig.isConfigured
            && self.businessId == BusinessConfig.businessId
            && self.appKey == BusinessConfig.appKey
            && self.bundleIdentifier == BusinessConfig.bundleIdentifier
            && AvailableTheme(rawValue: self.baseTheme) != nil
            && (self.schemaVersion == 1 || self.branding.radius?.isComplete == true)

    }

}
