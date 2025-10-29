//
//  EmployeeInvite.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/4/25.
//

import Foundation

struct EmployeeInvite: Identifiable, Hashable, Codable, Mockable {
    
    let id: String
    let name: String
    let email: String
    let businessId: String
    let businessName: String
    let locationIds: [String]
    let role: Role?
    let _createdAt: String?
    let _updatedAt: String?
    
    var createdAt: Date? {
        
        self._createdAt?
            .toDate(region: .local)?
            .date
        
    }
    
    var updatedAt: Date? {
        
        self._createdAt?
            .toDate(region: .local)?
            .date
        
    }
    
    var createdAtNoTimestamp: Date {
        return createDateWithTimestamp()
    }
    
    init(id: String,
         name: String,
         email: String,
         businessId: String,
         businessName: String,
         locationIds: [String] = [],
         role: Role? = nil,
         createdAt: String?) {
        
        self.id = id
        self.name = name
        self.email = email
        self.businessId = businessId
        self.businessName = businessName
        self.locationIds = locationIds
        self.role = role
        self._createdAt = createdAt
        self._updatedAt = createdAt
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case email
        case businessId = "business_id"
        case businessName = "business_name"
        case locationIds = "location_ids"
        case role
        case _createdAt = "created_at"
        case _updatedAt = "updated_at"
        
    }
    
    private func createDateWithTimestamp() -> Date {
        
        guard let createdAt else { return .now }
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: createdAt)) else {
            return .now
        }
        
        return date
        
    }
    
}

extension EmployeeInvite {
    
    static func DUMMY_DATA() -> EmployeeInvite {
        
        return .init(
            id: UUID().uuidString,
            name: "Sako Hovaguimian",
            email: "sako@hovaguimian.com",
            businessId: "1",
            businessName: "My Awesome Business",
            createdAt: Date().toISO()
        )
        
    }
    
}
