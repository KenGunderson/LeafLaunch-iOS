//
//  LocationEmployee.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/9/25.
//

import Foundation
 
struct LocationEmployee: Identifiable,
                         Equatable,
                         Hashable,
                         Codable,
                         Mockable {
    
    let id: String
    let businessId: String
    let locationId: String
    let employeeId: String
    let user: GPUser
    let role: Role
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case businessId = "business_id"
        case locationId = "location_id"
        case employeeId = "employee_id"
        case user
        case role
        
    }
    
}

extension LocationEmployee {
    
    static func DUMMY_DATA() -> Self {
        
        return .init(
            id: UUID().uuidString,
            businessId: MockModels.ID.business1,
            locationId: MockModels.ID.location1,
            employeeId: MockModels.ID.employee1,
            user: .DUMMY_DATA(),
            role: .manager
        )
        
    }
    
}

