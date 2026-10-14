import Foundation

// Rune radius values use logical points, including zero, bounded to 100 points.
// Omitted roles retain the built-in LeafLaunchThemeTokens radius values.
nonisolated struct StoreAppRadius: Codable, Equatable, Sendable {

    let extraSmall: Double?
    let small: Double?
    let small2: Double?
    let medium: Double?
    let medium2: Double?
    let large: Double?
    let extraLarge: Double?

    init(extraSmall: Double? = nil,
         small: Double? = nil,
         small2: Double? = nil,
         medium: Double? = nil,
         medium2: Double? = nil,
         large: Double? = nil,
         extraLarge: Double? = nil) {

        self.extraSmall = extraSmall
        self.small = small
        self.small2 = small2
        self.medium = medium
        self.medium2 = medium2
        self.large = large
        self.extraLarge = extraLarge

    }

    var isValid: Bool {

        [self.extraSmall, self.small, self.small2, self.medium, self.medium2, self.large, self.extraLarge]
            .compactMap { $0 }
            .allSatisfy { $0.isFinite && (0...100).contains($0) }

    }

    var isComplete: Bool {

        [self.extraSmall, self.small, self.small2, self.medium, self.medium2, self.large, self.extraLarge]
            .allSatisfy { $0 != nil }

    }

    private enum CodingKeys: String, CodingKey {

        case extraSmall = "extra_small"
        case small
        case small2
        case medium
        case medium2
        case large
        case extraLarge = "extra_large"

    }

}
