//
//  GhostOverlayCategory.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/19/25.
//

import Foundation

enum GhostOverlayCategory: String,
                           Hashable,
                           CaseIterable {
    
    case grid
    case head
    case eyes
    case nose
    case pokemon
    case digimon
    case other
    case custom
    
    var displayName: String {
        return self.rawValue.uppercased()
    }
    
    var images: [GhostOverlayView.GhostOverlayItem] {
        switch self {
        case .grid: return [.init(id: "1", image: .systemImage("person.fill")), .init(id: "2", image: .systemImage("house.fill"))]
        case .head: return [.init(id: "3", image: .systemImage("person.crop.square.on.square.angled")), .init(id: "4", image: .systemImage("person.crop.square.filled.and.at.rectangle.fill"))]
        case .eyes: return [.init(id: "5", image: .systemImage("sparkle")), .init(id: "6", image: .systemImage("sparkle"))]
        case .nose: return [.init(id: "6", image: .systemImage("person.fill")), .init(id: "7", image: .systemImage("house.fill"))]
        case .pokemon: return [.init(id: "8", image: .systemImage("person.fill")), .init(id: "9", image: .systemImage("house.fill"))]
        case .digimon: return [.init(id: "10", image: .systemImage("person.fill")), .init(id: "12", image: .systemImage("house.fill"))]
        case .other: return [.init(id: "13", image: .systemImage("person.fill")), .init(id: "14", image: .systemImage("house.fill"))]
        case .custom: return []
        }
    }
    
}
