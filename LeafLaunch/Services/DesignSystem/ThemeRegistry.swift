//
//  ThemeRegistry.swift
//  LeafLaunch
//

import SwiftUI

enum AvailableTheme: String, CaseIterable, Sendable {

    case light
    case dark

    var displayName: String {

        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        }

    }

    var iconName: String {

        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }

    }

    var toggled: AvailableTheme {

        switch self {
        case .light: return .dark
        case .dark: return .light
        }

    }

    init?(theme: any ThemeProtocol) {

        guard let availableTheme = Self.allCases.first(where: { $0.theme().id == theme.id }) else {
            return nil
        }

        self = availableTheme

    }

    func theme() -> Theme {

        switch self {
        case .light: return Theme.leafLaunchLight
        case .dark: return Theme.leafLaunchDark
        }

    }

    func foregroundColor() -> Color {
        return theme().foreground.primary.asColor ?? .black
    }

    func backgroundColor() -> Color {
        return theme().background.primary.asColor ?? .black
    }

}
