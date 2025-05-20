//
//  GPUser.swift
//  Grimoire
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
    let name: String
    let email: String
    let externalId: String
    let gender: Gender?
    let imageURL: URL?
    
    private var _birthday: String?
    
    var birthday: Date? {

        self._birthday?
            .toDate()?
            .date

    }
    
    var firstName: String {
        
        let nameComponents = self.name.components(separatedBy: " ")
        
        if nameComponents.count > 1 {
            return nameComponents[0]
        }
        
        return self.name.capitalized
        
    }
    
    init(id: String,
         name: String,
         email: String,
         externalId: String,
         birthday: String? = nil,
         gender: Gender? = nil,
         imageURL: URL? = nil) {
        
        self.id = id
        self.name = name
        self.email = email
        self.externalId = externalId
        self._birthday = birthday
        self.gender = gender
        self.imageURL = imageURL
        
    }
    
    mutating func setBirthday(dateString: String) {
        self._birthday = dateString
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case email
        case externalId = "external_id"
        case _birthday = "birthday"
        case gender
        case imageURL = "image_url"
        
    }
    
}

extension GPUser {
    
    static func DUMMY_DATA() -> Self {
        
        return .init(
            id: "1",
            name: "Sako Hovaguimian",
            email: "sako@me.com",
            externalId: "1",
            birthday: nil,
            gender: .male,
            imageURL: URL(string: "https://fastly.picsum.photos/id/580/200/300.jpg?hmac=ETV-og2PgiTBmJBERthfeRRRuLpWGxM4Zq_3z8pXndA")
        )
        
    }
    
}
