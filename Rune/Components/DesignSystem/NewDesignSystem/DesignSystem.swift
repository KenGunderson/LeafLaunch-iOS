//
//  DesignSystemProvider.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var designSystem: DesignSystemProviding = DesignSystem.shared
}

@Observable
class DesignSystem: DesignSystemProviding {
    
    static let shared = DesignSystem()
    
    var theme: any ThemeType = CustomTheme.GOLD_NAVY

    func updateTheme(_ theme: CustomTheme) {
        self.theme = theme
    }
    
    func background(_ key: CustomTheme.BackgroundKey) -> ColorSource {
        self.theme.background.value(for: key)
    }

    func spacing(_ key: CustomTheme.SpacingKey) -> CGFloat {
        self.theme.spacing.value(for: key)
    }

    func radius(_ key: CustomTheme.RadiusKey) -> CGFloat {
        self.theme.radius.value(for: key)
    }

    func font(_ key: CustomTheme.FontKey) -> Font {
        Font(self.theme.fonts.value(for: key))
    }

    func textColor(_ key: CustomTheme.TextColorKey) -> ColorSource {
        self.theme.textColor.value(for: key)
    }
    
    func shadow(_ key: CustomTheme.ShadowKey) -> CustomTheme.DecodableShadow {
        self.theme.shadow.value(for: key)
    }

    var accent: ColorSource { self.theme.accentColor }
    var titleTextColor: ColorSource { self.theme.textColor.title }
    
}
