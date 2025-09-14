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
    let phoneNumber: String?
    let imageURL: URL?
    let employeeId: String?
    let locationId: String?
    
    private var _dateOfBirth: String?
    
    var dateOfBirth: Date? {

        self._dateOfBirth?
            .toDate(region: .local)?
            .date

    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var hasEmailPhoneOrBirthday: Bool {
        return email != nil || phoneNumber != nil || dateOfBirth != nil
    }
    
    var dateOfBirthWithCurrentYear: Date {
        
        guard let dob = self.dateOfBirth else { return .now }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.month, .day], from: dob)
        components.year = calendar.component(.year, from: Date())
        
        guard let normalizedDate = calendar.date(from: components) else { return .now }
        return normalizedDate.date
        
    }
    
    init(id: String,
         firstName: String,
         lastName: String,
         email: String?,
         phone: String?,
         dateOfBirth: String? = nil,
         imageURL: URL? = nil,
         locationId: String? = nil,
         employeeId: String? = nil) {
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phone
        self._dateOfBirth = dateOfBirth
        self.imageURL = imageURL
        self.locationId = locationId
        self.employeeId = employeeId
        
    }
    
    mutating func setBirthday(dateString: String) {
        self._dateOfBirth = dateString
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phoneNumber = "phone_number"
        case _dateOfBirth = "date_of_birth"
        case imageURL = "image_url"
        case locationId = "location_id"
        case employeeId = "employee_id"
        
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
            dateOfBirth: nil,
            imageURL: URL(string: "https://fastly.picsum.photos/id/580/200/300.jpg?hmac=ETV-og2PgiTBmJBERthfeRRRuLpWGxM4Zq_3z8pXndA")
        )
        
    }
    
}
