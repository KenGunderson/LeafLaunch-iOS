//
//  Collage.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/18/25.
//

import Foundation

struct Collage: Identifiable,
                Equatable,
                Hashable,
                Codable,
                Mockable {
    
    static func == (lhs: Collage, rhs: Collage) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let locationId: String
    let clientId: String
    let mediaURLs: [URL]
    let rowCount: Int
    let columnCount: Int
    let type: CollageType
    
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
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case locationId = "location_id"
        case clientId = "client_id"
        
        case mediaURLs = "media_urls"
        
        case rowCount = "row_count"
        case columnCount = "column_count"
        case type
        
        case _createdAt = "created_at"
        case _updatedAt = "updated_at"
        
    }
    
    init(id: String,
         locationId: String,
         clientId: String,
         mediaURLs: [URL],
         rowCount: Int,
         columnCount: Int,
         type: CollageType,
         createdAt: Date? = nil,
         updatedAt: Date? = nil) {
        
        self.id = id
        self.locationId = locationId
        self.clientId = clientId
        self.mediaURLs = mediaURLs
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.type = type
        self._createdAt = createdAt?.ISO8601Format()
        self._updatedAt = updatedAt?.ISO8601Format()
        
    }
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.locationId = try container.decode(String.self, forKey: .locationId)
        self.clientId = try container.decode(String.self, forKey: .clientId)
        self.mediaURLs = try container.decode([URL].self, forKey: .mediaURLs)
        
        self.rowCount = try container.decode(Int.self, forKey: .rowCount)
        self.columnCount = try container.decode(Int.self, forKey: .columnCount)
        self._createdAt = try container.decodeIfPresent(String.self, forKey: ._createdAt)
        self._updatedAt = try container.decodeIfPresent(String.self, forKey: ._updatedAt)
        
        let typeString = try container.decode(String.self, forKey: .type)
        
        let isGrid = typeString == "GRID"
        let isOneLargeTwoSmall = typeString == "ONE_LARGE_TWO_SMALL"
        let isOneLargeOneSmall = typeString == "ONE_LARGE_ONE_SMALL"
        let isOneSmallOneLarge = typeString == "ONE_SMALL_ONE_LARGE"
        let isTwoLargeTwoSmall = typeString == "TWO_LARGE_TWO_SMALL"
        
        let gridType = CollageType.grid(rows: self.rowCount, columns: self.columnCount)
        
        if isGrid {
            self.type = gridType
        } else if isOneLargeTwoSmall {
            self.type = .oneLargeTwoSmall
        } else if isTwoLargeTwoSmall {
            self.type = .twoLargeTwoSmall
        } else if isOneLargeOneSmall {
            self.type = .oneLargeOneSmall
        } else if isOneSmallOneLarge {
            self.type = .oneSmallOneLarge
        } else {
            self.type = .grid(rows: 1, columns: 1)
        }
        
    }
    
}

extension Collage {
    
    static func DUMMY_DATA() -> Self {
    
        return .init(
            id: "1",
            locationId: "1",
            clientId: "1",
            mediaURLs: [URL(string: "https://www.google.com")!],
            rowCount: 1,
            columnCount: 1,
            type: .grid(rows: 1, columns: 2)
        )
        
    }
    
}
