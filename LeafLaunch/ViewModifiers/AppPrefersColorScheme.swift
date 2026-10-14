//
//  AppPrefersColorScheme.swift
//  Nudge
//
//  Created by Sako Hovaguimian on 4/14/26.
//

import SwiftUI

extension View {
    
    func appPrefersColorScheme() -> some View {
        modifier(AppPrefersColorSchemeModifier())
    }
    
}
