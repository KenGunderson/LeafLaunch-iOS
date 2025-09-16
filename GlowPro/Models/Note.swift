//
//  Note.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/13/25.
//

import Foundation

struct Note: Identifiable,
             Codable,
             Hashable,
             Equatable,
             Mockable {
    
    let id: String
    let clientId: String
    let employeeId: String
    
    let title: String
    let message: String
    let mediaURLs: [URL]
    
    private var _createdAt: String?
    
    var createdAt: Date? {

        self._createdAt?
            .toDate(region: .local)?
            .date

    }
    
    init(id: String,
         clientId: String,
         employeeId: String,
         title: String,
         message: String,
         mediaURLs: [URL] = [],
         createdAt: String) {
        
        self.id = id
        self.clientId = clientId
        self.employeeId = employeeId
        self.title = title
        self.message = message
        self.mediaURLs = mediaURLs
        self._createdAt = createdAt
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case clientId = "client_id"
        case employeeId = "employee_id"
        
        case title
        case message
        
        case mediaURLs = "media_urls"
        case _createdAt = "created_at"
        
    }
    
}

extension Note {
    
    static func DUMMY_DATA() -> Self {
        
        return .init(
            id: UUID().uuidString,
            clientId: "1",
            employeeId: "1",
            title: "My First Note",
            message: "This is my first note; I hope it works!",
            createdAt: Date().dateByAdding(-10, .day).toISO()
        )
        
    }
    
}
