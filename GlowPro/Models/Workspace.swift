//
//  Workspace.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/12/25.
//

import Foundation

struct Workspace: Codable,
                  Identifiable,
                  Hashable {
    
    struct RoleLocation: Codable,
                         Hashable {
        
        let role: Role
        let location: Location
        
        init(role: Role,
             location: Location) {
            
            self.role = role
            self.location = location
            
        }
        
    }
    
    let id: String
    let name: String
    let isOwner: Bool
    let roleLocations: [RoleLocation]
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case isOwner = "is_owner"
        case roleLocations = "role_with_locations"
        
    }

}
