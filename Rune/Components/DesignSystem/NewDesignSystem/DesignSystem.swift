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
    
    var theme: any ThemeType = CustomTheme.default

    func toggleTheme() {
        theme = (theme.id == "DEFAULT") ? CustomTheme.alternate : CustomTheme.default
    }
    
    func background(_ key: CustomTheme.BackgroundKey) -> ColorSource {
        theme.background.value(for: key)
    }

    func spacing(_ key: CustomTheme.SpacingKey) -> CGFloat {
        theme.spacing.value(for: key)
    }

    func radius(_ key: CustomTheme.RadiusKey) -> CGFloat {
        theme.radius.value(for: key)
    }

    func font(_ key: CustomTheme.FontKey) -> Font {
        theme.fonts.value(for: key)
    }

    func textColor(_ key: CustomTheme.TextColorKey) -> ColorSource {
        theme.textColor.value(for: key)
    }
    
    func shadow(_ key: CustomTheme.ShadowKey) -> CustomTheme.DecodableShadow {
        theme.shadow.value(for: key)
    }

    var accent: ColorSource { theme.accentColor }
    var titleTextColor: ColorSource { theme.textColor.title }
    
}
