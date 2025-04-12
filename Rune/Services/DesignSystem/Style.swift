//
//  Style.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var style: StyleProtocol = Style.shared
}

@Observable
class Style: StyleProtocol {
    
    static let shared = Style()
    
    var theme: any ThemeProtocol = Theme.GOLD_NAVY
    
    var accent: ColorSource { self.theme.accentColor }
    var titleTextColor: ColorSource { self.theme.textColor.title }

    func updateTheme(_ theme: Theme) {
        self.theme = theme
    }
    
    func background(_ key: Theme.BackgroundKey) -> ColorSource {
        self.theme.background.value(for: key)
    }

    func spacing(_ key: Theme.SpacingKey) -> CGFloat {
        self.theme.spacing.value(for: key)
    }

    func radius(_ key: Theme.RadiusKey) -> CGFloat {
        self.theme.radius.value(for: key)
    }

    func font(_ key: Theme.FontKey) -> Font {
        Font(self.theme.fonts.value(for: key))
    }

    func textColor(_ key: Theme.TextColorKey) -> ColorSource {
        self.theme.textColor.value(for: key)
    }
    
    func shadow(_ key: Theme.ShadowKey) -> Theme.DecodableShadow {
        self.theme.shadow.value(for: key)
    }
    
}
