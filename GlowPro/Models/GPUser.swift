//
//  GPUser.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import Foundation

protocol Mockable {
    
    static func DUMMY_DATA() -> Self
    
}

struct GPUser: Codable,
               Equatable,
               Hashable,
               Sendable,
               Mockable {
    
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let externalId: String
    let imageURL: URL?
    var businesses: [Business]?
    
    private var _birthday: String?
    
    var birthday: Date? {

        self._birthday?
            .toDate()?
            .date

    }
    
    var fullName: String {
        return self.firstName + " " + self.lastName
    }
    
    init(id: String,
         firstName: String,
         lastName: String,
         email: String,
         phoneNumber: String? = nil,
         externalId: String,
         birthday: String? = nil,
         imageURL: URL? = nil,
         businesses: [Business]? = []) {
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.externalId = externalId
        self._birthday = birthday
        self.imageURL = imageURL
        self.businesses = businesses
        
    }
    
    mutating func setBirthday(dateString: String) {
        self._birthday = dateString
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phoneNumber = "phone_number"
        case externalId = "external_id"
        case _birthday = "birthday"
        case imageURL = "image_url"
        case businesses = "businesses"
        
    }
    
}

extension GPUser {
    
    static func DUMMY_DATA() -> Self {
        
        return .init(
            id: "1",
            firstName: "Sako",
            lastName: "Hovaguimian",
            email: "sako@me.com",
            phoneNumber: "8185225755",
            externalId: "1",
            birthday: nil,
            imageURL: URL(string: "https://fastly.picsum.photos/id/580/200/300.jpg?hmac=ETV-og2PgiTBmJBERthfeRRRuLpWGxM4Zq_3z8pXndA"),
            businesses: []
        )
        
    }
    
}
