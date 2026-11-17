//
//  LLSpacing.swift
//  LeafLaunch
//

import SwiftUI

/// Layout responsibilities mapped to LeafLaunch's existing Rune spacing scale.
enum LLSpacing {

    static let none: RNTheme.SpacingKey = .none
    static let tightMetadata: RNTheme.SpacingKey = .custom(2)
    static let compact: RNTheme.SpacingKey = .custom(6)
    static let controlGroup: RNTheme.SpacingKey = .custom(10)
    static let content: RNTheme.SpacingKey = .large
    static let sectionGroup: RNTheme.SpacingKey = .large
    static let section: RNTheme.SpacingKey = .small2
    static let groupedContent: RNTheme.SpacingKey = .small
    static let metadata: RNTheme.SpacingKey = .extraSmall
    static let pageInset: RNTheme.SpacingKey = .medium
    static let navigationToContent: RNTheme.SpacingKey = .medium
    static let cardContent: RNTheme.SpacingKey = .small2
    static let listRow: RNTheme.SpacingKey = .medium
    static let formField: RNTheme.SpacingKey = .medium
    static let hero: RNTheme.SpacingKey = .large2

}
