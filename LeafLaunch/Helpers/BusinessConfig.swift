//
//  BusinessConfig.swift
//  LeafLaunch
//

import Foundation

// Every customer target supplies these constants through its own xcconfig and
// Info.plist. The API calls a business a Store; its public app key is separate.
enum BusinessConfig {

    static let businessId = configurationValue(for: "LeafLaunchBusinessId") ?? ""
    static let appKey = configurationValue(for: "LeafLaunchAppKey") ?? ""
    static let logoAssetName = configurationValue(for: "LeafLaunchLogoAssetName") ?? "App_Icon"
    static let bundleIdentifier = configurationValue(for: "LeafLaunchBundleIdentifier")
        ?? Bundle.main.bundleIdentifier
        ?? ""

    static var isConfigured: Bool {

        UUID(uuidString: businessId) != nil
            && UUID(uuidString: appKey) != nil
            && !bundleIdentifier.isEmpty
            && bundleIdentifier == Bundle.main.bundleIdentifier

    }

    private static func configurationValue(for key: String) -> String? {

        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedValue.isEmpty, !trimmedValue.contains("$(") else { return nil }
        return trimmedValue

    }

}
