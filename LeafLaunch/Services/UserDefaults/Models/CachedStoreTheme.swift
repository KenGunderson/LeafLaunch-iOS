//
//  CachedStoreTheme.swift
//  LeafLaunch
//

import Foundation

// RNTheme contains RNColorSource and UIFont and is not Codable. Cache the
// validated definition and reconstruct the actual RNTheme before rendering.
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

        let hasSupportedSchema = self.schemaVersion == 1 || self.schemaVersion == Self.currentSchemaVersion
        guard hasSupportedSchema, BusinessConfig.isConfigured else { return false }

        let matchesBusiness = self.businessId == BusinessConfig.businessId
        guard matchesBusiness else { return false }

        let matchesAppKey = self.appKey == BusinessConfig.appKey
        guard matchesAppKey else { return false }

        let matchesBundle = self.bundleIdentifier == BusinessConfig.bundleIdentifier
        guard matchesBundle, AvailableTheme(rawValue: self.baseTheme) != nil else { return false }

        return self.schemaVersion == 1 || self.branding.radius?.isComplete == true

    }

}
