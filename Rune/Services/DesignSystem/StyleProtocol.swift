//
//  StyleProtocol.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//

import SwiftUI

protocol StyleProtocol: AnyObject, Sendable {
    
    var theme: any ThemeProtocol { get }
    
    func updateTheme(_ theme: Theme)
    
    func background(_ key: Theme.BackgroundKey) -> ColorSource
    func spacing(_ key: Theme.SpacingKey) -> CGFloat
    func radius(_ key: Theme.RadiusKey) -> CGFloat
    func font(_ key: Theme.FontKey) -> Font
    func textColor(_ key: Theme.TextColorKey) -> ColorSource
    func shadow(_ key: Theme.ShadowKey) -> Theme.DecodableShadow
    
    var accent: ColorSource { get }
    var titleTextColor: ColorSource { get }
    
}
