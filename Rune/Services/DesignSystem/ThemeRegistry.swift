//
//  ThemeRegistry.swift
//  Rune2
//
//  Created by Sako Hovaguimian on 4/23/25.
//

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
        default: return Theme.GOLD_NAVY
        }
    }
    
}
