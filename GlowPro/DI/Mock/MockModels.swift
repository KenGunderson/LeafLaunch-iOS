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
        return [MockBusiness.business1, MockBusiness.business2, MockBusiness.business3]
    }
    
    static var allLocations: [Location] {
        return [MockLocation.location1, MockLocation.location2, MockLocation.location3]
    }
    
    static var allEmployees: [Employee] {
        return [MockEmployee.employee1, MockEmployee.employee2]
    }
    
    static var allEmployeeInvites: [EmployeeInvite] {
        return [MockEmployeeInvite.employeeInvite1, MockEmployeeInvite.employeeInvite2, MockEmployeeInvite.employeeInvite3]
    }
    
    static var allWorkspaces: [Workspace] {
        return [MockWorkspace.workspace1, MockWorkspace.workspace2]
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
    
    static var allMedia: [Media] {
        
        return [
            MockMedia.media1,
            MockMedia.media2,
            MockMedia.media3,
            MockMedia.media4,
            MockMedia.media5,
            MockMedia.media6,
            MockMedia.media7,
            MockMedia.media8,
            MockMedia.media9,
            MockMedia.media10,
            MockMedia.media11,
            MockMedia.media12,
            MockMedia.media13,
            MockMedia.media14,
            MockMedia.media15,
            MockMedia.media16,
            MockMedia.media17,
            MockMedia.media18,
            MockMedia.media19,
            MockMedia.media20,
            MockMedia.media21,
            MockMedia.media22,
            MockMedia.media23,
            MockMedia.media24,
            MockMedia.media25,
            MockMedia.media26,
            MockMedia.media27,
            MockMedia.media28,
            MockMedia.media29,
            MockMedia.media30
        ]
        
    }
    
    static var allMediaTags: [MediaTag] {
        
        return [
            MockMediaTag.mediaTag1,
            MockMediaTag.mediaTag2,
            MockMediaTag.mediaTag3,
            MockMediaTag.mediaTag4,
            MockMediaTag.mediaTag5
        ]
        
    }
    
    static var allActivities: [Activity] {
        
        return [
            MockActivity.activity1,
            MockActivity.activity2,
            MockActivity.activity3,
            MockActivity.activity4,
            MockActivity.activity5,
            MockActivity.activity6,
            MockActivity.activity7,
            MockActivity.activity8,
            MockActivity.activity9,
            MockActivity.activity10
        ]
        
    }
    
    struct ID {
        
        static let user1: String = UUID().uuidString
        static let user2: String = UUID().uuidString
        
        static let business1: String = UUID().uuidString
        static let business2: String = UUID().uuidString
        static let business3: String = UUID().uuidString
        
        static let location1: String = UUID().uuidString
        static let location2: String = UUID().uuidString
        static let location3: String = UUID().uuidString
        
        static let employee1: String = UUID().uuidString
        static let employee2: String = UUID().uuidString
        
        static let employeeInvite1: String = UUID().uuidString
        static let employeeInvite2: String = UUID().uuidString
        static let employeeInvite3: String = UUID().uuidString
        
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
        static let client11: String = UUID().uuidString
        
        static let media1: String = UUID().uuidString
        static let media2: String = UUID().uuidString
        static let media3: String = UUID().uuidString
        static let media4: String = UUID().uuidString
        static let media5: String = UUID().uuidString
        static let media6: String = UUID().uuidString
        static let media7: String = UUID().uuidString
        static let media8: String = UUID().uuidString
        static let media9: String = UUID().uuidString
        static let media10: String = UUID().uuidString
        static let media11: String = UUID().uuidString
        static let media12: String = UUID().uuidString
        static let media13: String = UUID().uuidString
        static let media14: String = UUID().uuidString
        static let media15: String = UUID().uuidString
        static let media16: String = UUID().uuidString
        static let media17: String = UUID().uuidString
        static let media18: String = UUID().uuidString
        static let media19: String = UUID().uuidString
        static let media20: String = UUID().uuidString
        static let media21: String = UUID().uuidString
        static let media22: String = UUID().uuidString
        static let media23: String = UUID().uuidString
        static let media24: String = UUID().uuidString
        static let media25: String = UUID().uuidString
        static let media26: String = UUID().uuidString
        static let media27: String = UUID().uuidString
        static let media28: String = UUID().uuidString
        static let media29: String = UUID().uuidString
        static let media30: String = UUID().uuidString
        static let media31: String = UUID().uuidString
        
        static let mediaTag1: String = UUID().uuidString
        static let mediaTag2: String = UUID().uuidString
        static let mediaTag3: String = UUID().uuidString
        static let mediaTag4: String = UUID().uuidString
        static let mediaTag5: String = UUID().uuidString
        
        static let activity1: String = UUID().uuidString
        static let activity2: String = UUID().uuidString
        static let activity3: String = UUID().uuidString
        static let activity4: String = UUID().uuidString
        static let activity5: String = UUID().uuidString
        static let activity6: String = UUID().uuidString
        static let activity7: String = UUID().uuidString
        static let activity8: String = UUID().uuidString
        static let activity9: String = UUID().uuidString
        static let activity10: String = UUID().uuidString
    }
    
    struct MockWorkspace {
        
        nonisolated(unsafe)
        static var workspace1: Workspace {
            Workspace(
                id: ID.business1,
                name: MockModels.MockBusiness.business1.name,
                isOwner: MockModels.MockBusiness.business1.owner.id == ID.user1,
                locations: MockModels.MockBusiness.business1.locations
            )
        }
        
        nonisolated(unsafe)
        static var workspace2: Workspace {
            Workspace(
                id: ID.business2,
                name: MockModels.MockBusiness.business2.name,
                isOwner: MockModels.MockBusiness.business2.owner.id == ID.user1,
                locations: MockModels.MockBusiness.business2.locations
            )
        }
        
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
            userId: MockModels.ID.user1,
            name: "Employee 1",
            email: "emp@me.com",
            phone: "999-999-9999",
            role: .employee
        )
        
        nonisolated(unsafe)
        static var employee2 = Employee(
            id: ID.employee2,
            businessId: ID.business2,
            locationId: ID.location2,
            userId: MockModels.ID.user2,
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
        
        nonisolated(unsafe)
        static var location3 = Location(
            id: ID.location3,
            businessId: ID.business3,
            name: "Newest Location",
            address: .DUMMY_DATA(),
            employees: [],
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
            owner: MockUser.user1,
            locations: [
                MockLocation.location1
            ],
            employeeInvites: [
                MockEmployeeInvite.employeeInvite1,
                MockEmployeeInvite.employeeInvite2,
            ]
        )
        
        nonisolated(unsafe)
        static var business2 = Business(
            id: ID.business2,
            name: "My Second Business",
            email: "business2@me.com",
            phoneNumber: "818-522-5755",
            address: .DUMMY_DATA(),
            owner: MockUser.user2,
            locations: [
                MockLocation.location2
            ]
        )
        
        nonisolated(unsafe)
        static var business3 = Business(
            id: ID.business3,
            name: "Body Sculpting Magic",
            email: "business3@me.com",
            phoneNumber: "818-522-5755",
            address: .DUMMY_DATA(),
            owner: MockUser.user2,
            locations: [
                MockLocation.location3
            ],
            employeeInvites: [
                MockEmployeeInvite.employeeInvite3,
            ]
        )
        
    }
    
    struct MockEmployeeInvite {
        
        nonisolated(unsafe)
        static var employeeInvite1 = EmployeeInvite(
            id: ID.employeeInvite1,
            name: "Sako Hovaguimian",
            email: "naruto@me.com",
            businessName: "My First Business"
        )
        
        nonisolated(unsafe)
        static var employeeInvite2 = EmployeeInvite(
            id: ID.employeeInvite2,
            name: "Monkey D. Luffy",
            email: "monkey@me.com",
            businessName: "My First Business"
        )
        
        nonisolated(unsafe)
        static var employeeInvite3 = EmployeeInvite(
            id: ID.employeeInvite3,
            name: "Sako Hovaguimian",
            email: "dope@me.com",
            businessName: "Body Sculpting Magic"
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
        
        nonisolated(unsafe)
        static var client11 = Client(
            id: ID.client11,
            firstName: "Mr.",
            lastName: "11",
            email: "cow@me.com",
            phone: "878-789-3232",
            birthDate: Date().addingTimeInterval(-23567).ISO8601Format(),
            imageURL: nil,
            locationId: ID.location2,
            employee: MockEmployee.employee2
        )
        
    }
    
    struct MockMedia {
        
        nonisolated(unsafe)
        static var media1: Media {
            Media(
                id: ID.media1,
                clientId: ID.client1,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/1/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-7438934),
                updatedAt: .now.addingTimeInterval(-437843)
            )
        }
        
        nonisolated(unsafe)
        static var media2: Media {
            Media(
                id: ID.media2,
                clientId: nil,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/2/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-343),
                updatedAt: .now.addingTimeInterval(-6521)
            )
        }
        
        nonisolated(unsafe)
        static var media3: Media {
            Media(
                id: ID.media3,
                clientId: ID.client1,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/3/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-231),
                updatedAt: .now.addingTimeInterval(-3453)
            )
        }
        
        nonisolated(unsafe)
        static var media4: Media {
            Media(
                id: ID.media4,
                clientId: ID.client1,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/4/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-1234),
                updatedAt: .now.addingTimeInterval(-9908)
            )
        }
        
        nonisolated(unsafe)
        static var media5: Media {
            Media(
                id: ID.media5,
                clientId: ID.client2,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/5/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-8054684034),
                updatedAt: .now.addingTimeInterval(-123)
            )
        }
        
        nonisolated(unsafe)
        static var media6: Media {
            Media(
                id: ID.media6,
                clientId: ID.client2,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/6/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-440394),
                updatedAt: .now.addingTimeInterval(-34934)
            )
        }
        
        nonisolated(unsafe)
        static var media7: Media {
            Media(
                id: ID.media7,
                clientId: nil,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/7/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-23904),
                updatedAt: .now.addingTimeInterval(-834)
            )
        }
        
        nonisolated(unsafe)
        static var media8: Media {
            Media(
                id: ID.media8,
                clientId: ID.client3,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/8/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-1983483),
                updatedAt: .now.addingTimeInterval(-98234)
            )
        }
        
        nonisolated(unsafe)
        static var media9: Media {
            Media(
                id: ID.media9,
                clientId: ID.client3,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/9/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-243),
                updatedAt: .now.addingTimeInterval(-43)
            )
        }
        
        nonisolated(unsafe)
        static var media10: Media {
            Media(
                id: ID.media10,
                clientId: ID.client1,
                businessId: ID.business2,
                url: URL(string: "https://picsum.photos/id/10/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-659438),
                updatedAt: .now.addingTimeInterval(-1534)
            )
        }
        
        nonisolated(unsafe)
        static var media11: Media {
            Media(
                id: ID.media11,
                clientId: ID.client1,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/11/1200/1200")!,
                isFavorited: true,
                createdAt: .now.addingTimeInterval(-12094),
                updatedAt: .now.addingTimeInterval(-783)
            )
        }
        
        nonisolated(unsafe)
        static var media12: Media {
            Media(
                id: ID.media12,
                clientId: ID.client2,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/12/1200/1200")!,
                isFavorited: true,
                createdAt: .now.addingTimeInterval(-2309483),
                updatedAt: .now.addingTimeInterval(-1043)
            )
        }
        
        nonisolated(unsafe)
        static var media13: Media {
            Media(
                id: ID.media13,
                clientId: nil,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/13/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-56433),
                updatedAt: .now.addingTimeInterval(-2343)
            )
        }
        
        nonisolated(unsafe)
        static var media14: Media {
            Media(
                id: ID.media14,
                clientId: ID.client4,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/14/1200/1200")!,
                isFavorited: true,
                createdAt: .now.addingTimeInterval(-1209834),
                updatedAt: .now.addingTimeInterval(-93483)
            )
        }
        
        nonisolated(unsafe)
        static var media15: Media {
            Media(
                id: ID.media15,
                clientId: ID.client2,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/15/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-834),
                updatedAt: .now.addingTimeInterval(-238)
            )
        }
        
        nonisolated(unsafe)
        static var media16: Media {
            Media(
                id: ID.media16,
                clientId: ID.client1,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/16/1200/1200")!,
                isFavorited: true,
                tags: [
                    MockMediaTag.mediaTag1
                ],
                createdAt: .now.addingTimeInterval(-2348234),
                updatedAt: .now.addingTimeInterval(-5433)
            )
        }
        
        nonisolated(unsafe)
        static var media17: Media {
            Media(
                id: ID.media17,
                clientId: nil,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/17/1200/1200")!,
                isFavorited: true,
                tags: [
                    MockMediaTag.mediaTag1,
                    MockMediaTag.mediaTag2,
                    MockMediaTag.mediaTag3
                ],
                createdAt: .now.addingTimeInterval(-45),
                updatedAt: .now.addingTimeInterval(-12)
            )
        }
        
        nonisolated(unsafe)
        static var media18: Media {
            Media(
                id: ID.media18,
                clientId: ID.client3,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/18/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-54334),
                updatedAt: .now.addingTimeInterval(-2345)
            )
        }
        
        nonisolated(unsafe)
        static var media19: Media {
            Media(
                id: ID.media19,
                clientId: ID.client2,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/19/1200/1200")!,
                isFavorited: true,
                createdAt: .now.addingTimeInterval(-34923),
                updatedAt: .now.addingTimeInterval(-893)
            )
        }
        
        nonisolated(unsafe)
        static var media20: Media {
            Media(
                id: ID.media20,
                clientId: ID.client4,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/20/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-489345),
                updatedAt: .now.addingTimeInterval(-5938)
            )
        }
        
        nonisolated(unsafe)
        static var media21: Media {
            Media(
                id: ID.media21,
                clientId: ID.client2,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/21/1200/1200")!,
                isFavorited: true,
                createdAt: .now.addingTimeInterval(-38234),
                updatedAt: .now.addingTimeInterval(-120)
            )
        }
        
        nonisolated(unsafe)
        static var media22: Media {
            Media(
                id: ID.media22,
                clientId: nil,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/22/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-234823),
                updatedAt: .now.addingTimeInterval(-324)
            )
        }
        
        nonisolated(unsafe)
        static var media23: Media {
            Media(
                id: ID.media23,
                clientId: ID.client4,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/23/1200/1200")!,
                isFavorited: true,
                createdAt: .now.addingTimeInterval(-3847),
                updatedAt: .now.addingTimeInterval(-938)
            )
        }
        
        nonisolated(unsafe)
        static var media24: Media {
            Media(
                id: ID.media24,
                clientId: ID.client1,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/24/1200/1200")!,
                isFavorited: true,
                createdAt: .now.addingTimeInterval(-82345),
                updatedAt: .now.addingTimeInterval(-49)
            )
        }
        
        nonisolated(unsafe)
        static var media25: Media {
            Media(
                id: ID.media25,
                clientId: ID.client2,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/25/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-48234),
                updatedAt: .now.addingTimeInterval(-9234)
            )
        }
        
        nonisolated(unsafe)
        static var media26: Media {
            Media(
                id: ID.media26,
                clientId: ID.client3,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/26/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-2134),
                updatedAt: .now.addingTimeInterval(-1293)
            )
        }
        
        nonisolated(unsafe)
        static var media27: Media {
            Media(
                id: ID.media27,
                clientId: nil,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/27/1200/1200")!,
                isFavorited: true,
                createdAt: .now.addingTimeInterval(-3124),
                updatedAt: .now.addingTimeInterval(-230)
            )
        }
        
        nonisolated(unsafe)
        static var media28: Media {
            Media(
                id: ID.media28,
                clientId: ID.client1,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/28/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-58234),
                updatedAt: .now.addingTimeInterval(-23984)
            )
        }
        
        nonisolated(unsafe)
        static var media29: Media {
            Media(
                id: ID.media29,
                clientId: ID.client4,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/29/1200/1200")!,
                isFavorited: true,
                createdAt: .now.addingTimeInterval(-8394),
                updatedAt: .now.addingTimeInterval(-324)
            )
        }
        
        nonisolated(unsafe)
        static var media30: Media {
            Media(
                id: ID.media30,
                clientId: ID.client3,
                businessId: ID.business1,
                url: URL(string: "https://picsum.photos/id/30/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-482394),
                updatedAt: .now.addingTimeInterval(-93234)
            )
        }
        
        nonisolated(unsafe)
        static var media31: Media {
            Media(
                id: ID.media31,
                clientId: ID.client11,
                businessId: ID.business2,
                url: URL(string: "https://picsum.photos/id/30/1200/1200")!,
                isFavorited: false,
                createdAt: .now.addingTimeInterval(-482394),
                updatedAt: .now.addingTimeInterval(-93234)
            )
        }
        
    }
    
    struct MockMediaTag {
     
        nonisolated(unsafe)
        static var mediaTag1: MediaTag {
            MediaTag(
                id: ID.mediaTag1,
                name: "Facials"
            )
        }
        
        nonisolated(unsafe)
        static var mediaTag2: MediaTag {
            MediaTag(
                id: ID.mediaTag2,
                name: "Acne"
            )
        }
        
        nonisolated(unsafe)
        static var mediaTag3: MediaTag {
            MediaTag(
                id: ID.mediaTag3,
                name: "Tattoo Removal"
            )
        }
        
        nonisolated(unsafe)
        static var mediaTag4: MediaTag {
            MediaTag(
                id: ID.mediaTag4,
                name: "Microblading"
            )
        }
        
        nonisolated(unsafe)
        static var mediaTag5: MediaTag {
            MediaTag(
                id: ID.mediaTag5,
                name: "Skincare"
            )
        }
        
    }
    
    struct MockActivity {
        
        nonisolated(unsafe)
        static var activity1: Activity {
            Activity(
                id: ID.activity1,
                title: "Initial Consultation",
                clientId: ID.client1,
                employeeId: ID.employee1,
                createdAt: Date().addingTimeInterval(-83493).toISO()
            )
        }
        
        nonisolated(unsafe)
        static var activity2: Activity {
            Activity(
                id: ID.activity2,
                title: "Follow-up Call",
                clientId: ID.client1,
                employeeId: ID.employee1,
                createdAt: Date().addingTimeInterval(-42384).toISO()
            )
        }
        
        nonisolated(unsafe)
        static var activity3: Activity {
            Activity(
                id: ID.activity3,
                title: "Scheduled Appointment",
                clientId: ID.client1,
                employeeId: ID.employee1,
                createdAt: Date().addingTimeInterval(-23984).toISO()
            )
        }
        
        nonisolated(unsafe)
        static var activity4: Activity {
            Activity(
                id: ID.activity4,
                title: "Consultation Completed",
                clientId: ID.client1,
                employeeId: ID.employee2,
                createdAt: Date().addingTimeInterval(-834).toISO()
            )
        }
        
        nonisolated(unsafe)
        static var activity5: Activity {
            Activity(
                id: ID.activity5,
                title: "Sent Email Follow-up",
                clientId: ID.client1,
                employeeId: ID.employee1,
                createdAt: Date().addingTimeInterval(-34923).toISO()
            )
        }
        
        nonisolated(unsafe)
        static var activity6: Activity {
            Activity(
                id: ID.activity6,
                title: "First Procedure",
                clientId: ID.client2,
                employeeId: ID.employee1,
                createdAt: Date().addingTimeInterval(-234234).toISO()
            )
        }
        
        nonisolated(unsafe)
        static var activity7: Activity {
            Activity(
                id: ID.activity7,
                title: "Shared Pre-Visit Instructions",
                clientId: ID.client1,
                employeeId: ID.employee2,
                createdAt: Date().addingTimeInterval(-99834).toISO()
            )
        }
        
        nonisolated(unsafe)
        static var activity8: Activity {
            Activity(
                id: ID.activity8,
                title: "Sent Invoice",
                clientId: ID.client2,
                employeeId: ID.employee1,
                createdAt: Date().addingTimeInterval(-5384).toISO()
            )
        }
        
        nonisolated(unsafe)
        static var activity9: Activity {
            Activity(
                id: ID.activity9,
                title: "Payment Received",
                clientId: ID.client1,
                employeeId: ID.employee1,
                createdAt: Date().addingTimeInterval(-324).toISO()
            )
        }
        
        nonisolated(unsafe)
        static var activity10: Activity {
            Activity(
                id: ID.activity10,
                title: "Treatment Follow-up",
                clientId: ID.client1,
                employeeId: ID.employee2,
                createdAt: Date().addingTimeInterval(-84923).toISO()
            )
        }
        
    }
    
}
