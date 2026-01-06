//
//  MockModels.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/16/25.
//

import Foundation

struct MockModels {
    
    static var allUsers: [GPUser] {
        return [MockUser.user1, MockUser.user2]
    }
    
    struct ID {
        
        static let user1: String = UUID().uuidString
        static let user2: String = UUID().uuidString
        
    }
    
    struct MockUser {
        
        nonisolated(unsafe)
        static var user1 = GPUser(
            id: ID.user1,
            firstName: "Sako",
            lastName: "Hovaguimian",
            email: "sako@me.com",
            phoneNumber: "8185225755",
            externalId: "1",
            dateOfBirth: Date().addingTimeInterval(-34587).ISO8601Format(),
            imageURL: nil
        )
        
        nonisolated(unsafe)
        static var user2 = GPUser(
            id: ID.user2,
            firstName: "KC",
            lastName: "Gunserson",
            email: "kc@me.com",
            phoneNumber: "8185225755",
            externalId: "2",
            dateOfBirth: Date().addingTimeInterval(-123903).ISO8601Format(),
            imageURL: nil
        )
        
    }
    
}
