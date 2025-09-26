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
    
    case face
    case neck
    case arms
    case chest
    case abdomen
    case hips
    
    var displayName: String {
        return self.rawValue.uppercased()
    }
    
    var images: [GhostOverlayView.GhostOverlayItem] {
        return [.init(id: "1", image: .systemImage("person.fill")), .init(id: "2", image: .systemImage("house.fill"))]
    }
    
}
