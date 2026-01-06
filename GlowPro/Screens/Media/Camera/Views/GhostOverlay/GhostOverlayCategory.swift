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
        switch self {
        case .ghost: return "Ghost Photo"
        case .head: return "Head"
        case .neck: return "Neck"
        case .chest: return "Chest"
        case .arms: return "Arms"
        case .abdomen: return "Abdomen"
        case .hips: return "Hips"
        }
    }
    
    var images: [GhostOverlayView.GhostOverlayItem] {
        
        switch self {
            
        case .ghost:
            return [.init(id: "CUSTOM", image: .systemImage("photo"))]
            
        case .head:
            
            return [
                .init(id: "1", image: .image(.headFront, renderingMode: .template)),
                .init(id: "2", image: .image(.headProfileLeft, renderingMode: .template)),
                .init(id: "3", image: .image(.headProfileRight, renderingMode: .template)),
                .init(id: "4", image: .image(.head45Left, renderingMode: .template)),
                .init(id: "5", image: .image(.head45Right, renderingMode: .template)),
            ]
          
        case .neck:
            
            return [
                .init(id: "6", image: .image(.neckFront, renderingMode: .template)),
                .init(id: "7", image: .image(.neckProfileLeft, renderingMode: .template)),
                .init(id: "8", image: .image(.neckProfileRight, renderingMode: .template)),
                .init(id: "9", image: .image(.neckTiltedProfileDownLeft, renderingMode: .template)),
                .init(id: "10", image: .image(.neckTiltedProfileDownRight, renderingMode: .template)),
            ]
            
        case .chest:
            
            return [
                .init(id: "11", image: .image(.torsoFront, renderingMode: .template)),
                .init(id: "12", image: .image(.torsoBack, renderingMode: .template)),
                .init(id: "13", image: .image(.torsoChestLeft, renderingMode: .template)),
                .init(id: "14", image: .image(.torsoChestRight, renderingMode: .template)),
            ]
            
        case .arms:
            
            return [
                .init(id: "15", image: .image(.armLeft, renderingMode: .template)),
                .init(id: "16", image: .image(.armRight, renderingMode: .template)),
                .init(id: "17", image: .image(.armBentLeft, renderingMode: .template)),
                .init(id: "18", image: .image(.armBentRight, renderingMode: .template)),
            ]
            
        case .abdomen:
            
            return [
                .init(id: "19", image: .image(.abFront, renderingMode: .template)),
                .init(id: "20", image: .image(.abBack, renderingMode: .template)),
                .init(id: "21", image: .image(.abLeft, renderingMode: .template)),
                .init(id: "22", image: .image(.abRight, renderingMode: .template)),
            ]
            
        case .hips:
            
            return [
                .init(id: "23", image: .image(.hipFront, renderingMode: .template)),
                .init(id: "24", image: .image(.hipBack, renderingMode: .template)),
                .init(id: "25", image: .image(.hipProLeft, renderingMode: .template)),
                .init(id: "26", image: .image(.hipProRight, renderingMode: .template)),
            ]
        }
        
    }
    
}
