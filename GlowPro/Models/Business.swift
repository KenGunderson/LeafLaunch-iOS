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
    let owner: GPUser
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
    var totalMediaTagCount: Int
    var totalFormsCount: Int
    
    var businessSettings: BusinessSetting?
    
    let stripeCustomerId: String?
    var subscription: StripeSubscription?
    var stripeSubscriptionProduct: StripeSubscriptionProduct?
    let isSubscribed: Bool
    
    init(id: String,
         name: String,
         description: String? = nil,
         email: String? = nil,
         phoneNumber: String? = nil,
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
         totalMediaTagCount: Int = 0,
         totalFormsCount: Int = 0,
         clientsWithBirthdaysThisMonth: [Client] = [],
         stripeCustomerId: String? = nil,
         subscription: StripeSubscription? = nil,
         stripeSubscriptionProduct: StripeSubscriptionProduct? = nil) {
        
        self.id = id
        self.name = name
        self.description = description
        self.email = email
        self.phoneNumber = phoneNumber
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
        self.totalMediaTagCount = totalMediaTagCount
        self.totalFormsCount = totalFormsCount
        self.clientsWithBirthdaysThisMonth = clientsWithBirthdaysThisMonth
        self.businessSettings = nil
        self.stripeCustomerId = stripeCustomerId
        self.subscription = subscription
        self.stripeSubscriptionProduct = stripeSubscriptionProduct
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case description
        case email
        case phoneNumber = "phone_number"
        case owner
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
        case totalMediaTagCount = "total_media_tags"
        case totalFormsCount = "total_forms"
        case clientsWithBirthdaysThisMonth = "clients_with_birthdays_this_month"
        case businessSettings = "business_setting"

        case stripeCustomerId = "stripe_customer_id"
        case subscription
        case stripeSubscriptionProduct = "stripe_subscription_product"
        case isSubscribed = "is_subscribed"

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
            owner: .DUMMY_DATA(),
            locations: [],
        )
        
    }
    
}
