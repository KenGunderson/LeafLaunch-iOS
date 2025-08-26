//
//  Location.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/1/25.
//

import Foundation

struct Location: Identifiable,
                 Equatable,
                 Hashable,
                 Codable,
                 Mockable {
    
    let id: String
    let businessId: String
    let name: String
    let address: Address
    var employees: [Employee]
    var clients: [Client]
    var media: [Media] = []
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case businessId = "business_id"
        case name
        case address
        case employees
        case clients
        case media
        
    }
    
}

extension Location {
    
    static func DUMMY_DATA() -> Location {
        return .init(
            id: UUID().uuidString,
            businessId: Bool.random() ? MockModels.ID.business1 : MockModels.ID.business2,
            name: "My First Location",
            address: .DUMMY_DATA(),
            employees: [],
            clients: [],
            media: []
        )
    }
    
}
