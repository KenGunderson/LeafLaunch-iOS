//
//  Activity.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import Foundation

struct Activity: Codable, Mockable {
    
    let id: String
    let title: String
    let clientId: String
    let employeeId: String
    let _createdAt: String?
    
    var createdAt: Date? {
        
        self._createdAt?
            .toDate()?
            .date
        
    }
    
    var createdAtNoTimestamp: Date!
    
    init(id: String,
         title: String,
         clientId: String,
         employeeId: String,
         createdAt: String?) {
        
        self.id = id
        self.title = title
        self.clientId = clientId
        self.employeeId = employeeId
        self._createdAt = createdAt
        self.createdAtNoTimestamp = createDateWithTimestamp()
        
    }
    
    public enum CodingKeys: String, CodingKey {
        
        case id
        case title
        case clientId = "client_id"
        case employeeId = "employee_id"
        case _createdAt = "created_at"
        
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
            title: "Called Client",
            clientId: "1",
            employeeId: "1",
            createdAt: Date().toISO()
        )
        
    }
    
}
