//
//  FullScreenCover.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/16/24.
//

enum FullScreenCover: Identifiable, Hashable, Equatable {

    case settings
    case devSettings
    case onboarding
    case clientDetails(clientId: String)
    case mediaTags(selectedMedia: Media)

    var id: String {
        return String(self.hashValue)
    }
    
    static func == (lhs: FullScreenCover, rhs: FullScreenCover) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case .devSettings: return hasher.combine(0)
        case .onboarding: return hasher.combine(1)
        case .settings: return hasher.combine(2)
        case .clientDetails(let clientId): return hasher.combine(clientId)
        case .mediaTags(let selectedMedia): return hasher.combine(selectedMedia.id)
        }
        
    }
    
}
