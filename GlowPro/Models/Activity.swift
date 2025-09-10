//
//  Activity.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import Foundation

struct Activity: Codable, Mockable {
    
    let id: String
    let clientId: String?
    let authorId: String
    let businessId: String
    let locationId: String?
    let activityType: ActivityType
    let _createdAt: String?
    let _updatedAt: String?
    
    var createdAt: Date? {
        
        self._createdAt?
            .toDate()?
            .date
        
    }
    
    var updatedAt: Date? {
        
        self._createdAt?
            .toDate()?
            .date
        
    }
    
    var createdAtNoTimestamp: Date {
        return createDateWithTimestamp()
    }
    
    init(id: String,
         clientId: String?,
         authorId: String,
         businessId: String,
         locationId: String?,
         activityType: ActivityType,
         createdAt: String?) {
        
        self.id = id
        self.clientId = clientId
        self.authorId = authorId
        self.businessId = businessId
        self.locationId = locationId
        self.activityType = activityType
        self._createdAt = createdAt
        self._updatedAt = createdAt
        
    }
    
    public enum CodingKeys: String, CodingKey {
        
        case id
        case clientId = "client_id"
        case authorId = "author_id"
        case businessId = "business_id"
        case locationId = "location_id"
        case activityType = "type"
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

extension Activity {
    
    static func DUMMY_DATA() -> Self {
        
        return .init(
            id: "1",
            clientId: "1",
            authorId: "1",
            businessId: "1",
            locationId: nil,
            activityType: .businessCreated,
            createdAt: Date().toISO()
        )
        
    }
    
}
