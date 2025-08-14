//
//  Business.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import Foundation


struct Business: Identifiable,
                 Equatable,
                 Hashable,
                 Codable,
                 Mockable {
    
    let id: String
    let name: String
    let description: String?
    let email: String?
    let phoneNumber: String?
    let address: Address?
    let owner: GPUser
    let employees: [Employee]
    let locations: [Location]
    var employeeInvites: [EmployeeInvite]
    
    init(id: String,
         name: String,
         description: String? = nil,
         email: String? = nil,
         phoneNumber: String? = nil,
         address: Address? = nil,
         owner: GPUser,
         employees: [Employee] = [],
         locations: [Location] = [],
         employeeInvites: [EmployeeInvite] = []) {
        
        self.id = id
        self.name = name
        self.description = description
        self.email = email
        self.phoneNumber = phoneNumber
        self.address = address
        self.owner = owner
        self.employees = employees
        self.locations = locations
        self.employeeInvites = employeeInvites
        
    }
        
}

extension Business {
    
    static func DUMMY_DATA() -> Self {
        
        let id = UUID().uuidString
        
        return .init(
            id: id,
            name: "The Hallal Guys",
            description: "This is the business description",
            email: "hallalguy@gmail.com",
            phoneNumber: "818-522-5755",
            address: .DUMMY_DATA(),
            owner: .DUMMY_DATA(),
            locations: [],
        )
        
    }
    
}
