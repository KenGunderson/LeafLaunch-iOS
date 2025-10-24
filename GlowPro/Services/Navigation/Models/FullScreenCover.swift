//
//  FullScreenCover.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import Foundation

enum FullScreenCover: Identifiable, Hashable, Equatable {

    case settings
    case devSettings
    case onboarding
    
    case mediaTags(selectedMedia: Media?)
    case mediaMultiTags(selectedMedia: [Media])
    case mediaPreview(url: URL)

    case subscriptionPaywall

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
        case .mediaTags(let selectedMedia): return hasher.combine(selectedMedia?.id)
        case .mediaMultiTags(let selectedMedia): return hasher.combine(selectedMedia.first?.id)
        case .mediaPreview(let url): return hasher.combine(url.absoluteString)
        case .subscriptionPaywall: return hasher.combine(0)
        }
        
    }
    
}
