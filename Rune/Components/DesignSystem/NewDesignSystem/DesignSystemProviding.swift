//
//  DesignSystemProviding.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

protocol DesignSystemProviding: AnyObject {
    
    var theme: any ThemeType { get }
    
    func toggleTheme()
    
    func background(_ key: CustomTheme.BackgroundKey) -> ColorSource
    func spacing(_ key: CustomTheme.SpacingKey) -> CGFloat
    func radius(_ key: CustomTheme.RadiusKey) -> CGFloat
    func font(_ key: CustomTheme.FontKey) -> Font
    func textColor(_ key: CustomTheme.TextColorKey) -> ColorSource
    func shadow(_ key: CustomTheme.ShadowKey) -> CustomTheme.DecodableShadow
    
    var accent: ColorSource { get }
    var titleTextColor: ColorSource { get }
    
}
