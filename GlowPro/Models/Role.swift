//
//  Role.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/10/25.
//

enum Role: String,
           CaseIterable,
           Codable,
           Selectable {
    
    var id: String {
        return self.rawValue
    }
    
    case employee
    case frontDesk
    case manager
    case owner
    
    var description: String {
        switch self {
        case .employee: return "Employee"
        case .frontDesk: return "Front Desk"
        case .manager: return "Manager"
        case .owner: return "Owner"
        }
    }
    
}
