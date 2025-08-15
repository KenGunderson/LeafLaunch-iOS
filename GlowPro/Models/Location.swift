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
    let employees: [Employee]
    let clients: [Client]
    
    var fullFormattedAddress: String {
        
        var string = ""
        string += "\(address.street),"
        
        if let street = address.street2 {
            string += " \(street),"
        }
        
        string += "\n\(address.city), \(address.zip) \(address.state)"
        return string
        
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
            clients: []
        )
    }
    
}
