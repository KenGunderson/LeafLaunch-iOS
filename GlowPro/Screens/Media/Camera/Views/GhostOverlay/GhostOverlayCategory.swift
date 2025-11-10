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
    
    case ghost
    case head
    case neck
    case chest
    case arms
    case abdomen
    case hips
    
    var displayName: String {
        return self.rawValue.uppercased()
    }
    
    var images: [GhostOverlayView.GhostOverlayItem] {
        
        switch self {
            
        case .ghost:
            return [.init(id: "CUSTOM", image: .systemImage("photo"))]
            
        case .head:
            
            return [
                .init(id: "1", image: .image(.headFront)),
                .init(id: "2", image: .image(.headProfileLeft)),
                .init(id: "3", image: .image(.headProfileRight)),
                .init(id: "4", image: .image(.head45Left)),
                .init(id: "5", image: .image(.head45Right)),
            ]
          
        case .neck:
            
            return [
                .init(id: "6", image: .image(.neckFront)),
                .init(id: "7", image: .image(.neckProfileLeft)),
                .init(id: "8", image: .image(.neckProfileRight)),
                .init(id: "9", image: .image(.neckTiltedProfileLeft)),
                .init(id: "10", image: .image(.neckTiltedProfileRight)),
            ]
            
        case .chest:
            
            return [
                .init(id: "11", image: .image(.torsoFront)),
                .init(id: "12", image: .image(.torsoBack)),
                .init(id: "13", image: .image(.torsoChestLeft)),
                .init(id: "14", image: .image(.torsoChestRight)),
            ]
            
        case .arms:
            
            return [
                .init(id: "15", image: .image(.armLeft)),
                .init(id: "16", image: .image(.armRight)),
                .init(id: "17", image: .image(.armBentLeft)),
                .init(id: "18", image: .image(.armBentRight)),
            ]
            
        case .abdomen:
            
            return [
                .init(id: "19", image: .image(.abFront)),
                .init(id: "20", image: .image(.abBack)),
                .init(id: "21", image: .image(.abLeft)),
                .init(id: "22", image: .image(.abRight)),
            ]
            
        case .hips:
            
            return [
                .init(id: "23", image: .image(.hipFront)),
                .init(id: "24", image: .image(.hipBack)),
                .init(id: "25", image: .image(.hipProLeft)),
                .init(id: "26", image: .image(.hipProRight)),
            ]
        }
        
    }
    
}
