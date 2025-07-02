//
//  Location.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/1/25.
//

import Foundation

struct Location: Identifiable,
                 Codable,
                 Mockable {
    
    let id: String
    let businessId: String
    let name: String
    let address: Address
    let employees: [Employee]
    let clients: [Client]
    
}

extension Location {
    
    static func DUMMY_DATA() -> Location {
        return .init(
            id: UUID().uuidString,
            businessId: "123",
            name: "My First Business",
            address: .DUMMY_DATA(),
            employees: [.DUMMY_DATA()],
            clients: [.DUMMY_DATA()]
        )
    }
    
}
