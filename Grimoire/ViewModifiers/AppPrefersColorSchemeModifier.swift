//
//  AppPrefersColorSchemeModifier.swift
//  Grimoire
//
//  Created by Codex on 7/11/26.
//

import SwiftUI

struct AppPrefersColorSchemeModifier: ViewModifier {

    @Environment(\.style) private var style

    func body(content: Content) -> some View {
        content.preferredColorScheme(self.style.theme.isLightMode ? .light : .dark)
    }

}
