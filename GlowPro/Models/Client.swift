//
//  Client.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import Foundation

struct Client: Codable,
               Equatable,
               Hashable,
               Sendable,
               Mockable {
    
    let id: String
    let firstName: String
    let lastName: String
    let email: String?
    let phone: String?
    let imageURL: URL?
    let employeeId: String?
    let locationId: String?
    let employee: Employee
    
    private var _birthDate: String?
    
    var birthDate: Date? {

        self._birthDate?
            .toDate()?
            .date

    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var hasEmailPhoneOrBirthday: Bool {
        return email != nil || phone != nil || birthDate != nil
    }
    
    init(id: String,
         firstName: String,
         lastName: String,
         email: String?,
         phone: String?,
         birthDate: String? = nil,
         imageURL: URL? = nil,
         locationId: String? = nil,
         employeeId: String? = nil,
         employee: Employee) {
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self._birthDate = birthDate
        self.imageURL = imageURL
        self.locationId = locationId
        self.employeeId = employeeId
        self.employee = employee
        
    }
    
    mutating func setBirthday(dateString: String) {
        self._birthDate = dateString
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
        case _birthDate = "birth_date"
        case imageURL = "image_url"
        case locationId = "location_id"
        case employeeId = "employee_id"
        case employee
        
    }
    
}

extension Client {
    
    static func DUMMY_DATA() -> Self {
        
        return .init(
            id: "1",
            firstName: "Sako",
            lastName: "Hovaguimian",
            email: "sako@me.com",
            phone: "8185225755",
            birthDate: nil,
            imageURL: URL(string: "https://fastly.picsum.photos/id/580/200/300.jpg?hmac=ETV-og2PgiTBmJBERthfeRRRuLpWGxM4Zq_3z8pXndA"),
            employee: .DUMMY_DATA()
        )
        
    }
    
}
