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
    
    case admin = "ADMIN"
    case owner = "OWNER"
    case manager = "MANAGER"
    case employee = "EMPLOYEE"
    case receptionist = "RECEPTIONIST"
    
    var description: String {
        switch self {
        case .admin: return "Admin"
        case .owner: return "Owner"
        case .manager: return "Manager"
        case .employee: return "Practitioner"
        case .receptionist: return "Assistant"
        }
    }
    
    static let LocationRoles: [Role] = [.manager, .employee, .receptionist]
    
}
