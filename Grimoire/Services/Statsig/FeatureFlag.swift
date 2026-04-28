//
//  FeatureFlag.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/27/26.
//

// MARK: - FeatureFlag

enum FeatureFlag: String, CaseIterable {

    // Add cases here. The raw value must match the gate name in the Statsig console.
    // Example:
    // case newOnboardingFlow = "new_onboarding_flow"
    // case premiumContentGating = "premium_content_gating"

    case exampleFlag = "example_flag"

    var displayName: String {
        switch self {
        case .exampleFlag: return "Example Flag"
        }
    }

    var defaultValue: Bool {
        switch self {
        case .exampleFlag: return false
        }
    }

}
