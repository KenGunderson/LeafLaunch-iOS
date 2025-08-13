//
//  Workspace.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/12/25.
//

import Foundation

struct Workspace: Codable, Identifiable, Hashable {
    
    let id: String
    let name: String
    let isOwner: Bool
    let locations: [Location]
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case isOwner = "is_owner"
        case locations
        
    }
    
}
