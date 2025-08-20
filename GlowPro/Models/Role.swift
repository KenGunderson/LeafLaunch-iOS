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
    
    case admin
    case owner
    case manager
    case employee
    case receptionist
    
    var description: String {
        switch self {
        case .admin: return "Admin"
        case .owner: return "Owner"
        case .manager: return "Manager"
        case .employee: return "Employee"
        case .receptionist: return "Receptionist"
        }
    }
    
    static var LocationRoles: [Role] {
        return [.manager, .employee, .receptionist]
    }
    
}
