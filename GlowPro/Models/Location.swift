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
    var employees: [LocationEmployee]
    var clients: [Client]
    var media: [Media] = []
    var clientsWithBirthdaysThisMonth: [Client] = []
    
    var totalClientCount: Int
    var totalEmployeeCount: Int
    var totalMediaCount: Int
    var totalCollageCount: Int
    var totalDiagramCount: Int
    
    init(id: String,
         businessId: String,
         name: String,
         address: Address,
         employees: [LocationEmployee] = [],
         clients: [Client] = [],
         media: [Media] = [],
         totalClientCount: Int = 0,
         totalEmployeeCount: Int = 0,
         totalMediaCount: Int = 0,
         totalCollageCount: Int = 0,
         totalDiagramCount: Int = 0,
         clientsWithBirthdaysThisMonth: [Client] = []) {
        
        self.id = id
        self.businessId = businessId
        self.name = name
        self.address = address
        self.employees = employees
        self.clients = clients
        self.media = media
        self.totalClientCount = totalClientCount
        self.totalEmployeeCount = totalEmployeeCount
        self.totalMediaCount = totalMediaCount
        self.totalCollageCount = totalCollageCount
        self.totalDiagramCount = totalDiagramCount
        self.clientsWithBirthdaysThisMonth = clientsWithBirthdaysThisMonth
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case businessId = "business_id"
        case name
        case address
        case employees
        case clients
        case media
        
        case totalClientCount = "total_clients"
        case totalEmployeeCount = "total_employees"
        case totalMediaCount = "total_media"
        case totalCollageCount = "total_collages"
        case totalDiagramCount = "total_diagrams"
        
        case clientsWithBirthdaysThisMonth = "clients_with_birthdays_this_month"
        
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
            media: [],
            totalClientCount: 0,
            totalEmployeeCount: 0,
            totalMediaCount: 0
        )
    }
    
}
