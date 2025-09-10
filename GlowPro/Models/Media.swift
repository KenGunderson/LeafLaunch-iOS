//
//  Media.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/19/25.
//

import Foundation

enum MediaSortingOption: String,
                    CaseIterable,
                    Selectable {
    
    var id: String {
        return self.rawValue
    }
    
    case newest
    case oldest
    case favorited
    
    var description: String {
        switch self {
        case .newest: return "Newest"
        case .oldest: return "Oldest"
        case .favorited: return "Favorited"
        }
    }
    
}

struct MediaTag: Identifiable,
                 Equatable,
                 Codable,
                 Hashable {
    
    let id: String
    let name: String
    
    init(id: String,
         name: String) {
        
        self.id = id
        self.name = name
        
    }
    
    init(name: String) {
        
        self.id = UUID().uuidString
        self.name = name
        
    }
    
}

struct Media: Identifiable,
              Equatable,
              Codable,
              Hashable,
              Mockable {
    
    let id: String
    let clientId: String?
    let businessId: String
    let locationId: String
    let authorId: String
    let url: URL
    var isFavorited: Bool
    var tags: [MediaTag]
    
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
         locationId: String,
         authorId: String,
         url: URL,
         isFavorited: Bool,
         tags: [MediaTag] = [],
         createdAt: Date? = nil,
         updatedAt: Date? = nil) {
        
        self.id = id
        self.clientId = clientId
        self.businessId = businessId
        self.locationId = locationId
        self.authorId = authorId
        self.url = url
        self.isFavorited = isFavorited
        self.tags = tags
        self._createdAt = createdAt?.ISO8601Format()
        self._updatedAt = updatedAt?.ISO8601Format()
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case clientId = "client_id"
        case businessId = "business_id"
        case locationId = "location_id"
        case authorId = "author_id"
        case url
        case tags
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
            locationId: "1",
            authorId: "1",
            url: URL(string: "https://www.google.com")!,
            isFavorited: false
        )
        
    }
    
}
