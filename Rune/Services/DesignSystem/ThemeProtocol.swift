//
//  ThemeProtocol.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

protocol ThemeProtocol: Identifiable, Equatable, Sendable {
    
    var id: String { get }
    var accentColor: ColorSource { get }
    var accentColorSecondary: ColorSource { get }
    var background: Theme.Background { get }
    var textColor: Theme.TextColor { get }
    var spacing: Theme.Spacing { get }
    var radius: Theme.Radius { get }
    var fonts: Theme.Fonts { get }
    var shadow: Theme.Shadow { get }
    
}
