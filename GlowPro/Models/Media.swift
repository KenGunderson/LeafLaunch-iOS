//
//  Media.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/19/25.
//

import Foundation
import SwiftUI

enum MediaSortingOption: String,
                    CaseIterable,
                    Selectable {
    
    var id: String {
        return self.rawValue
    }
    
    case newest
    case oldest
    case favorited
    case onlyUntagged
    
    var description: String {
        switch self {
        case .newest: return "Newest"
        case .oldest: return "Oldest"
        case .favorited: return "Favorited"
        case .onlyUntagged: return "Untagged"
        }
    }
    
    var queryParameter: String {
        switch self {
        case .newest: return "desc"
        case .oldest: return "asc"
        case .favorited: return "desc"
        case .onlyUntagged: return "desc"
        }
    }
    
}

enum MediaType: String,
                CaseIterable,
                Codable,
                Selectable {
    
    var id: String {
        return self.rawValue
    }
    
    case image = "IMAGE"
    case collage = "COLLAGE"
    case diagram = "DIAGRAM"
    case imageAnnotation = "IMAGE_ANNOTATION"
    case diagramAnnotation = "DIAGRAM_ANNOTATION"
    
    var description: String {
        switch self {
        case .image: return "Image"
        case .collage: return "Collage"
        case .diagram: return "Diagram"
        case .imageAnnotation: return "Image Annotation"
        case .diagramAnnotation: return "Diagram Annotation"
        }
    }
    
    var queryParameter: String {
        switch self {
        case .image: return "IMAGE"
        case .collage: return "COLLAGE"
        case .diagram: return "DIAGRAM"
        case .imageAnnotation: return "IMAGE_ANNOTATION"
        case .diagramAnnotation: return "DIAGRAM_ANNOTATION"
        }
    }
    
    var color: Color {
        switch self {
        case .image: ActivityCategory.camera.color
        case .collage: ActivityCategory.collage.color
        case .diagram: ActivityCategory.form.color
        case .imageAnnotation: ActivityCategory.camera.color
        case .diagramAnnotation: ActivityCategory.form.color
        }
    }
    
    static var DISPLAY_CASES: [MediaType] {
        return [.image, .collage, .diagram]
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
              Sendable,
              Mockable {
    
    let id: String
    let clientId: String?
    let businessId: String
    let locationId: String
    let authorId: String
    let url: URL
    var isFavorited: Bool
    var tags: [MediaTag]
    var mediaType: MediaType
    
    private var _createdAt: String?
    private var _updatedAt: String?
    
    var createdAt: Date? {

        self._createdAt?
            .toDate(region: .local)?
            .date

    }
    
    var updatedAt: Date? {

        self._updatedAt?
            .toDate(region: .local)?
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
         mediaType: MediaType = .image,
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
        self.mediaType = mediaType
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
        case mediaType = "media_type"
        case isFavorited = "is_favorited"
        case _createdAt = "created_at"
        case _updatedAt = "updated_at"
        
    }
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.clientId = try container.decodeIfPresent(String.self, forKey: .clientId)
        self.businessId = try container.decode(String.self, forKey: .businessId)
        self.locationId = try container.decode(String.self, forKey: .locationId)
        self.authorId = try container.decode(String.self, forKey: .authorId)
        self.url = try container.decode(URL.self, forKey: .url)
        self.tags = try container.decode([MediaTag].self, forKey: .tags)
        self.mediaType = try container.decodeIfPresent(MediaType.self, forKey: .mediaType) ?? .image
        self.isFavorited = try container.decode(Bool.self, forKey: .isFavorited)
        self._createdAt = try container.decodeIfPresent(String.self, forKey: ._createdAt)
        self._updatedAt = try container.decodeIfPresent(String.self, forKey: ._updatedAt)
        
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
