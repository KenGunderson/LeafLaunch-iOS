//
//  Media.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/19/25.
//

import Foundation

struct Media: Identifiable,
              Equatable,
              Codable,
              Hashable,
              Mockable {
    
    let id: String
    let clientId: String?
    let businessId: String
    let url: URL
    let isFavorited: Bool
    
    private var _createdAt: String?
    private var _updatedAt: String?
    
    var createdAt: Date? {

        self._createdAt?
            .toDate()?
            .date

    }
    
    var updatedAt: Date? {

        self._updatedAt?
            .toDate()?
            .date
        
    }
    
    init(id: String,
         clientId: String?,
         businessId: String,
         url: URL,
         isFavorited: Bool,
         createdAt: Date? = nil,
         updatedAt: Date? = nil) {
        
        self.id = id
        self.clientId = clientId
        self.businessId = businessId
        self.url = url
        self.isFavorited = isFavorited
        self._createdAt = createdAt?.ISO8601Format()
        self._updatedAt = updatedAt?.ISO8601Format()
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case clientId = "client_id"
        case businessId = "business_id"
        case url
        case isFavorited = "is_favorited"
        case _createdAt = "created_at"
        case _updatedAt = "updated_at"
        
    }
    
}

extension Media {
    
    static func DUMMY_DATA() -> Self {
        
        return .init(
            id: UUID().uuidString,
            clientId: "1",
            businessId: "1",
            url: URL(string: "https://www.google.com")!,
            isFavorited: false
        )
        
    }
    
}
