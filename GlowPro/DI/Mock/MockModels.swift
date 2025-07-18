//
//  MockModels.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/16/25.
//

import Foundation

struct MockModels {
    
    static var allUsers: [GPUser] {
        return [MockUser.user1, MockUser.user2]
    }
    
    static var allBusinesses: [Business] {
        return [MockBusiness.business1, MockBusiness.business2]
    }
    
    static var allLocations: [Location] {
        return [MockLocation.location1, MockLocation.location2]
    }
    
    static var allEmployees: [Employee] {
        return [MockEmployee.employee1, MockEmployee.employee2]
    }
    
    static var allClients: [Client] {
        
        return [
            MockClient.client1,
            MockClient.client2,
            MockClient.client3,
            MockClient.client4,
            MockClient.client5,
            MockClient.client6,
            MockClient.client7,
            MockClient.client8,
            MockClient.client9,
            MockClient.client10,
        ]
        
    }
    
    struct ID {
        
        static let user1: String = UUID().uuidString
        static let user2: String = UUID().uuidString
        
        static let business1: String = UUID().uuidString
        static let business2: String = UUID().uuidString
        
        static let location1: String = UUID().uuidString
        static let location2: String = UUID().uuidString
        
        static let employee1: String = UUID().uuidString
        static let employee2: String = UUID().uuidString
        
        static let client1: String = UUID().uuidString
        static let client2: String = UUID().uuidString
        static let client3: String = UUID().uuidString
        static let client4: String = UUID().uuidString
        static let client5: String = UUID().uuidString
        static let client6: String = UUID().uuidString
        static let client7: String = UUID().uuidString
        static let client8: String = UUID().uuidString
        static let client9: String = UUID().uuidString
        static let client10: String = UUID().uuidString
        
    }
    
    struct MockUser {
        
        nonisolated(unsafe)
        static var user1 = GPUser(
            id: ID.user1,
            name: "Sako Hovaguimian",
            email: "sako@me.com",
            externalId: "1",
            birthday: Date().addingTimeInterval(-34587).ISO8601Format(),
            gender: .male,
            imageURL: nil,
            businesses: [
                
            ]
        )
        
        nonisolated(unsafe)
        static var user2 = GPUser(
            id: ID.user2,
            name: "KC Gunserson",
            email: "kc@me.com",
            externalId: "2",
            birthday: Date().addingTimeInterval(-123903).ISO8601Format(),
            gender: .male,
            imageURL: nil,
            businesses: [
                
            ]
        )
        
    }
    
    struct MockEmployee {
        
        nonisolated(unsafe)
        static var employee1 = Employee(
            id: ID.employee1,
            businessId: ID.business1,
            locationId: ID.location1,
            name: "Employee 1",
            email: "emp@me.com",
            phone: "999-999-9999",
            role: .employee
        )
        
        nonisolated(unsafe)
        static var employee2 = Employee(
            id: ID.employee2,
            businessId: ID.business1,
            locationId: ID.location1,
            name: "Employee 2",
            email: "emp2@me.com",
            phone: "999-999-9999",
            role: .employee
        )
        
    }
    
    struct MockLocation {
     
        nonisolated(unsafe)
        static var location1 = Location(
            id: ID.location1,
            businessId: ID.business1,
            name: "First Location",
            address: .DUMMY_DATA(),
            employees: [MockEmployee.employee1, MockEmployee.employee2],
            clients: []
        )
        
        nonisolated(unsafe)
        static var location2 = Location(
            id: ID.location2,
            businessId: ID.business2,
            name: "Second Location",
            address: .DUMMY_DATA(),
            employees: [MockEmployee.employee1, MockEmployee.employee2],
            clients: []
        )
        
    }
    
    struct MockBusiness {
        
        nonisolated(unsafe)
        static var business1 = Business(
            id: ID.business1,
            name: "My First Business",
            email: "business@me.com",
            phoneNumber: "818-522-5755",
            address: .DUMMY_DATA(),
            locations: [
                MockLocation.location1,
                MockLocation.location2,
            ],
            owner: MockUser.user1
        )
        
        nonisolated(unsafe)
        static var business2 = Business(
            id: ID.business2,
            name: "My Second Business",
            email: "business2@me.com",
            phoneNumber: "818-522-5755",
            address: .DUMMY_DATA(),
            locations: [
                MockLocation.location2
            ],
            owner: MockUser.user1
        )
        
    }
    
    struct MockClient {
     
        nonisolated(unsafe)
        static var client1 = Client(
            id: ID.client1,
            firstName: "Joe",
            lastName: "Smith",
            email: "joe@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-785849).ISO8601Format(),
            imageURL: nil,
            employee: MockEmployee.employee1
        )
        
        nonisolated(unsafe)
        static var client2 = Client(
            id: ID.client2,
            firstName: "Mary",
            lastName: "Glover",
            email: "mary@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-4456).ISO8601Format(),
            imageURL: nil,
            employee: MockEmployee.employee1
        )
        
        nonisolated(unsafe)
        static var client3 = Client(
            id: ID.client3,
            firstName: "Justin",
            lastName: "Bieber",
            email: "jb@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-234234).ISO8601Format(),
            imageURL: nil,
            employee: MockEmployee.employee1
        )
        
        nonisolated(unsafe)
        static var client4 = Client(
            id: ID.client4,
            firstName: "Wanda",
            lastName: "Bison",
            email: "cow@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-23567).ISO8601Format(),
            imageURL: nil,
            employee: MockEmployee.employee1
        )
        
        nonisolated(unsafe)
        static var client5 = Client(
            id: ID.client5,
            firstName: "John",
            lastName: "Sharpe",
            email: "js@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-23567).ISO8601Format(),
            imageURL: nil,
            employee: MockEmployee.employee1
        )
        
        nonisolated(unsafe)
        static var client6 = Client(
            id: ID.client6,
            firstName: "Robert",
            lastName: "Sharpe",
            email: "rs@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-23567).ISO8601Format(),
            imageURL: nil,
            employee: MockEmployee.employee1
        )
        
        nonisolated(unsafe)
        static var client7 = Client(
            id: ID.client7,
            firstName: "Leon",
            lastName: "Hovaguimian",
            email: "lh@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-4564).ISO8601Format(),
            imageURL: nil,
            employee: MockEmployee.employee1
        )
        
        nonisolated(unsafe)
        static var client8 = Client(
            id: ID.client8,
            firstName: "Dan",
            lastName: "Winkle",
            email: "dw@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-4578948).ISO8601Format(),
            imageURL: nil,
            employee: MockEmployee.employee1
        )
        
        nonisolated(unsafe)
        static var client9 = Client(
            id: ID.client9,
            firstName: "Evan",
            lastName: "Sharpe",
            email: "es@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-4563).ISO8601Format(),
            imageURL: nil,
            employee: MockEmployee.employee1
        )
        
        nonisolated(unsafe)
        static var client10 = Client(
            id: ID.client10,
            firstName: "Mr.",
            lastName: "10",
            email: "cow@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-23567).ISO8601Format(),
            imageURL: nil,
            employee: MockEmployee.employee1
        )
        
    }
    
}
