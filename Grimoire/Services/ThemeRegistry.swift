//
//  ThemeRegistry.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import Foundation

enum AvailableTheme: String, CaseIterable {
    
    case goldNavy
    case goldLight
    case coralTwilight
    case neonNight
    case emaraldNoir
    case sandstomeDusk
    
    func theme() -> Theme {
        
        switch self {
        case .goldNavy: return Theme.GOLD_NAVY
        case .goldLight: return Theme.GOLD_LIGHT
        case .emaraldNoir: return Theme.EMERALD_NOIR
        case .coralTwilight: return Theme.CORAL_TWILIGHT
        case .neonNight: return Theme.NEON_NIGHT
        case .sandstomeDusk: return Theme.SANDSTONE_DUSK
        }
        
    }
    
}
