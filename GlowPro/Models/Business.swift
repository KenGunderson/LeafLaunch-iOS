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
    let isSubscribed: Bool
    let categories: [String]
    let subcategories: [String]
    var employees: [Employee]
    var locations: [Location]
    var employeeInvites: [EmployeeInvite]
    var media: [Media]
    var clientsWithBirthdaysThisMonth: [Client] = []
    
    var totalLocationCount: Int
    var totalClientCount: Int
    var totalEmployeeCount: Int
    var totalMediaCount: Int
    
    init(id: String,
         name: String,
         description: String? = nil,
         email: String? = nil,
         phoneNumber: String? = nil,
         address: Address? = nil,
         owner: GPUser,
         isSubscribed: Bool = false,
         categories: [String] = [],
         subcategories: [String] = [],
         employees: [Employee] = [],
         locations: [Location] = [],
         media: [Media] = [],
         employeeInvites: [EmployeeInvite] = [],
         totalLocationCount: Int = 0,
         totalClientCount: Int = 0,
         totalEmployeeCount: Int = 0,
         totalMediaCount: Int = 0,
         clientsWithBirthdaysThisMonth: [Client] = []) {
        
        self.id = id
        self.name = name
        self.description = description
        self.email = email
        self.phoneNumber = phoneNumber
        self.address = address
        self.owner = owner
        self.isSubscribed = isSubscribed
        self.categories = categories
        self.subcategories = subcategories
        self.employees = employees
        self.locations = locations
        self.media = media
        self.employeeInvites = employeeInvites
        self.totalLocationCount = totalLocationCount
        self.totalClientCount = totalClientCount
        self.totalEmployeeCount = totalEmployeeCount
        self.totalMediaCount = totalMediaCount
        self.clientsWithBirthdaysThisMonth = clientsWithBirthdaysThisMonth
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case description
        case email
        case phoneNumber = "phone_number"
        case address
        case owner
        case isSubscribed = "is_subscribed"
        case categories
        case subcategories
        case employees
        case locations
        case employeeInvites = "employee_invites"
        case media
        case totalLocationCount = "total_locations"
        case totalClientCount = "total_clients"
        case totalEmployeeCount = "total_employees"
        case totalMediaCount = "total_media"
        case clientsWithBirthdaysThisMonth = "clients_with_birthdays_this_month"
        
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
