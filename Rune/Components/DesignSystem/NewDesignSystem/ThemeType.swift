//
//  ThemeType.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

protocol ThemeType: Identifiable, Equatable {
    
    var id: String { get }
    var accentColor: ColorSource { get }
    var accentColorSecondary: ColorSource { get }
    var background: CustomTheme.Background { get }
    var textColor: CustomTheme.TextColor { get }
    var spacing: CustomTheme.Spacing { get }
    var radius: CustomTheme.Radius { get }
    var fonts: CustomTheme.Fonts { get }
    var shadow: CustomTheme.Shadow { get }
    
}
