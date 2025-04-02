//
//  ThemeChoice.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/1/25.
//


import SwiftUI

extension EnvironmentValues {
    
    @Entry var themeManager = ThemeManager.shared
    
}

@Observable
class ThemeManager {
    
    static let shared = ThemeManager()
    
    private(set) var theme: Theme = .GOLD_NAVY

    func updateTheme(_ theme: Theme) {
        self.theme = theme
    }

    func accentColor() -> Color {
        self.theme.accentColor
    }
    
    func textColor(_ type: Theme.TextColor) -> Color {
        self.theme.textColor(type)
    }

    func background(_ type: Theme.Background) -> Color {
        self.theme.background(type)
    }
    
    func accentGradient() -> AnyGradient {
        return self.theme.accentColorGradient
    }

    func backgroundGradient() -> AnyGradient {
        return self.theme.backgroundGradient
    }
    
}

