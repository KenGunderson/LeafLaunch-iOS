//
//  CompanyStats.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/31/25.
//

import Foundation

struct CompanyStats: Equatable,
                     Hashable,
                     Codable,
                     Mockable {

    let totals: CompanyTotals
    let groupedTotals: CompanyGroupedTotals
    let averages: CompanyAverages
    let featureRequests: CompanyFeatureRequestContainer
    let infrastructure: CompanyInfrastructure
    let downtrend: CompanyDowntrend
    let growth: CompanyGrowth

    init(totals: CompanyTotals,
         groupedTotals: CompanyGroupedTotals,
         averages: CompanyAverages,
         featureRequests: CompanyFeatureRequestContainer,
         infrastructure: CompanyInfrastructure,
         downtrend: CompanyDowntrend,
         growth: CompanyGrowth) {

        self.totals = totals
        self.groupedTotals = groupedTotals
        self.averages = averages
        self.featureRequests = featureRequests
        self.infrastructure = infrastructure
        self.downtrend = downtrend
        self.growth = growth

    }

    private enum CodingKeys: String, CodingKey {

        case totals
        case groupedTotals = "grouped_totals"
        case averages
        case featureRequests = "feature_requests"
        case infrastructure
        case downtrend
        case growth

    }

}

extension CompanyStats {

    static func DUMMY_DATA() -> Self {

        let totals = CompanyTotals(
            totalUsers: 12_345,
            totalBusinesses: 321,
            totalEmployees: 1_024,
            totalClients: 18_900,
            totalLocations: 640,
            totalMedia: 250_000,
            totalMediaFavorites: 14_200,
            totalSubscriptions: 290,
            totalFeatureRequests: 87
        )

        let groupedTotals = CompanyGroupedTotals(
            groupedActivities: [
                .init(activityType: "media_upload", count: 1200),
                .init(activityType: "login", count: 5400),
            ],
            groupedCategories: [
                .init(category: "Med Spa", count: 120),
                .init(category: "Salon", count: 85),
            ],
            groupedSubcategories: [
                .init(subcategory: "Injectables", count: 70),
                .init(subcategory: "Laser", count: 55),
            ],
            groupedLocationStates: [
                .init(state: "CA", count: 210),
                .init(state: "NV", count: 35),
            ]
        )

        let averages = CompanyAverages(
            avgClientsPerBusiness: 58.3,
            avgLocationsPerBusiness: 2.1,
            avgMediaPerClient: 6.7,
            avgMediaFavoritesPerLocation: 14.0
        )

        let featureRequests = CompanyFeatureRequestContainer(
            featureRequests: [
                .init(
                    id: UUID().uuidString,
                    userId: UUID().uuidString,
                    message: "Add bulk media tagging + search.",
                    createdAt: Date().ISO8601Format()
                ),
                .init(
                    id: UUID().uuidString,
                    userId: UUID().uuidString,
                    message: "Offline mode for client profiles.",
                    createdAt: Date().ISO8601Format()
                )
            ]
        )

        let infrastructure = CompanyInfrastructure(
            activeSubscriptions: 290,
            businessesWithNoLocations: 4,
            employeesWithoutLocations: 12,
            unlinkedMedia: 9,
            businessesWithoutSubscriptions: 31
        )

        let deletedLocation = CompanyDeletedLocationWithMedia(
            businessId: UUID().uuidString,
            businessName: "GlowPro Demo Business",
            locationId: UUID().uuidString,
            locationName: "Las Vegas - Summerlin",
            deletedAt: "2025-12-12T18:10:00.000Z",
            mediaCount: 220
        )

        let subscriptionData = CompanySubscriptionData(
            businessId: UUID().uuidString,
            businessName: "GlowPro Demo Business",
            ownerId: UUID().uuidString,
            ownerName: "Sako Hovaguimian",
            ownerEmail: "sako@example.com",
            monthsSubscribed: 9,
            subscriptionId: UUID().uuidString,
            createdAt: "2025-03-01T00:00:00.000Z"
        )

        let downtrend = CompanyDowntrend(
            deletedLocationsWithMediaCount: 2,
            deletedLocationsWithMediaTotalMedia: 340,
            deletedLocationsWithMedia: [deletedLocation],
            cancelledSubscriptionsCount: 5,
            tierUpdateScheduleCount: 11,
            downgradesInScheduleCount: 7,
            tierUpdateSchedule: [subscriptionData],
            subscribedBusinessCount: 290
        )

        let growth = CompanyGrowth(
            interval: .days30,
            users: .init(added: 450, pctOfTotal: 0.036),
            businesses: .init(added: 22, pctOfTotal: 0.068),
            clients: .init(added: 980, pctOfTotal: 0.052),
            media: .init(added: 8_400, pctOfTotal: 0.033),
            subscriptions: .init(added: 14, pctOfTotal: 0.048)
        )

        return .init(
            totals: totals,
            groupedTotals: groupedTotals,
            averages: averages,
            featureRequests: featureRequests,
            infrastructure: infrastructure,
            downtrend: downtrend,
            growth: growth
        )

    }

}

// MARK: - Totals

struct CompanyTotals: Equatable,
                      Hashable,
                      Codable {

    let totalUsers: Int
    let totalBusinesses: Int
    let totalEmployees: Int
    let totalClients: Int
    let totalLocations: Int
    let totalMedia: Int
    let totalMediaFavorites: Int
    let totalSubscriptions: Int
    let totalFeatureRequests: Int

    init(totalUsers: Int,
         totalBusinesses: Int,
         totalEmployees: Int,
         totalClients: Int,
         totalLocations: Int,
         totalMedia: Int,
         totalMediaFavorites: Int,
         totalSubscriptions: Int,
         totalFeatureRequests: Int) {

        self.totalUsers = totalUsers
        self.totalBusinesses = totalBusinesses
        self.totalEmployees = totalEmployees
        self.totalClients = totalClients
        self.totalLocations = totalLocations
        self.totalMedia = totalMedia
        self.totalMediaFavorites = totalMediaFavorites
        self.totalSubscriptions = totalSubscriptions
        self.totalFeatureRequests = totalFeatureRequests

    }

    private enum CodingKeys: String, CodingKey {

        case totalUsers = "total_users"
        case totalBusinesses = "total_businesses"
        case totalEmployees = "total_employees"
        case totalClients = "total_clients"
        case totalLocations = "total_locations"
        case totalMedia = "total_media"
        case totalMediaFavorites = "total_media_favorites"
        case totalSubscriptions = "total_subscriptions"
        case totalFeatureRequests = "total_feature_requests"

    }

}

// MARK: - Grouped Totals

struct CompanyGroupedTotals: Equatable,
                             Hashable,
                             Codable {

    let groupedActivities: [CompanyActivityGroup]
    let groupedCategories: [CompanyCategoryGroup]
    let groupedSubcategories: [CompanySubcategoryGroup]
    let groupedLocationStates: [CompanyLocationStatesGroup]

    init(groupedActivities: [CompanyActivityGroup],
         groupedCategories: [CompanyCategoryGroup],
         groupedSubcategories: [CompanySubcategoryGroup],
         groupedLocationStates: [CompanyLocationStatesGroup]) {

        self.groupedActivities = groupedActivities
        self.groupedCategories = groupedCategories
        self.groupedSubcategories = groupedSubcategories
        self.groupedLocationStates = groupedLocationStates

    }

    private enum CodingKeys: String, CodingKey {

        case groupedActivities = "grouped_activities"
        case groupedCategories = "grouped_categories"
        case groupedSubcategories = "grouped_subcategories"
        case groupedLocationStates = "grouped_location_states"

    }

}

struct CompanyActivityGroup: Equatable,
                             Hashable,
                             Codable {

    let activityType: String
    let count: Int

    init(activityType: String,
         count: Int) {

        self.activityType = activityType
        self.count = count

    }

    private enum CodingKeys: String, CodingKey {

        case activityType = "activity_type"
        case count

    }

}

struct CompanyCategoryGroup: Equatable,
                             Hashable,
                             Codable {

    let category: String
    let count: Int

    init(category: String,
         count: Int) {

        self.category = category
        self.count = count

    }

}

struct CompanySubcategoryGroup: Equatable,
                                Hashable,
                                Codable {

    let subcategory: String
    let count: Int

    init(subcategory: String,
         count: Int) {

        self.subcategory = subcategory
        self.count = count

    }

}

struct CompanyLocationStatesGroup: Equatable,
                                  Hashable,
                                  Codable {

    let state: String
    let count: Int

    init(state: String,
         count: Int) {

        self.state = state
        self.count = count

    }

}

// MARK: - Averages

struct CompanyAverages: Equatable,
                        Hashable,
                        Codable {

    let avgClientsPerBusiness: Double
    let avgLocationsPerBusiness: Double
    let avgMediaPerClient: Double
    let avgMediaFavoritesPerLocation: Double

    init(avgClientsPerBusiness: Double,
         avgLocationsPerBusiness: Double,
         avgMediaPerClient: Double,
         avgMediaFavoritesPerLocation: Double) {

        self.avgClientsPerBusiness = avgClientsPerBusiness
        self.avgLocationsPerBusiness = avgLocationsPerBusiness
        self.avgMediaPerClient = avgMediaPerClient
        self.avgMediaFavoritesPerLocation = avgMediaFavoritesPerLocation

    }

    private enum CodingKeys: String, CodingKey {

        case avgClientsPerBusiness = "avg_clients_per_business"
        case avgLocationsPerBusiness = "avg_locations_per_business"
        case avgMediaPerClient = "avg_media_per_client"
        case avgMediaFavoritesPerLocation = "avg_media_favorites_per_location"

    }

}

// MARK: - Feature Requests

struct CompanyFeatureRequestContainer: Equatable,
                                       Hashable,
                                       Codable {

    let featureRequests: [CompanyFeatureRequest]

    init(featureRequests: [CompanyFeatureRequest]) {

        self.featureRequests = featureRequests

    }

    private enum CodingKeys: String, CodingKey {

        case featureRequests = "feature_requests"

    }

}

struct CompanyFeatureRequest: Identifiable,
                              Equatable,
                              Hashable,
                              Codable {
    
    let id: String
    let userId: String
    let message: String
    
    private let _createdAt: String?
    var createdAt: Date? {
        
        self._createdAt?
            .toDate(region: .local)?
            .date
        
    }
    
    init(id: String,
         userId: String,
         message: String,
         createdAt: String?) {
        
        self.id = id
        self.userId = userId
        self.message = message
        self._createdAt = createdAt
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case userId = "user_id"
        case message
        case _createdAt = "created_at"
        
    }

}

// MARK: - Infrastructure

struct CompanyInfrastructure: Equatable,
                              Hashable,
                              Codable {

    let activeSubscriptions: Int
    let businessesWithNoLocations: Int
    let employeesWithoutLocations: Int
    let unlinkedMedia: Int
    let businessesWithoutSubscriptions: Int

    init(activeSubscriptions: Int,
         businessesWithNoLocations: Int,
         employeesWithoutLocations: Int,
         unlinkedMedia: Int,
         businessesWithoutSubscriptions: Int) {

        self.activeSubscriptions = activeSubscriptions
        self.businessesWithNoLocations = businessesWithNoLocations
        self.employeesWithoutLocations = employeesWithoutLocations
        self.unlinkedMedia = unlinkedMedia
        self.businessesWithoutSubscriptions = businessesWithoutSubscriptions

    }

    private enum CodingKeys: String, CodingKey {

        case activeSubscriptions = "active_subscriptions"
        case businessesWithNoLocations = "businesses_with_no_locations"
        case employeesWithoutLocations = "employees_without_locations"
        case unlinkedMedia = "unlinked_media"
        case businessesWithoutSubscriptions = "businesses_without_subscriptions"

    }

}

// MARK: - Downtrend

struct CompanyDowntrend: Equatable,
                         Hashable,
                         Codable {

    let deletedLocationsWithMediaCount: Int
    let deletedLocationsWithMediaTotalMedia: Int
    let deletedLocationsWithMedia: [CompanyDeletedLocationWithMedia]
    let cancelledSubscriptionsCount: Int
    let tierUpdateScheduleCount: Int
    let downgradesInScheduleCount: Int
    let tierUpdateSchedule: [CompanySubscriptionData]
    let subscribedBusinessCount: Int

    init(deletedLocationsWithMediaCount: Int,
         deletedLocationsWithMediaTotalMedia: Int,
         deletedLocationsWithMedia: [CompanyDeletedLocationWithMedia],
         cancelledSubscriptionsCount: Int,
         tierUpdateScheduleCount: Int,
         downgradesInScheduleCount: Int,
         tierUpdateSchedule: [CompanySubscriptionData],
         subscribedBusinessCount: Int) {

        self.deletedLocationsWithMediaCount = deletedLocationsWithMediaCount
        self.deletedLocationsWithMediaTotalMedia = deletedLocationsWithMediaTotalMedia
        self.deletedLocationsWithMedia = deletedLocationsWithMedia
        self.cancelledSubscriptionsCount = cancelledSubscriptionsCount
        self.tierUpdateScheduleCount = tierUpdateScheduleCount
        self.downgradesInScheduleCount = downgradesInScheduleCount
        self.tierUpdateSchedule = tierUpdateSchedule
        self.subscribedBusinessCount = subscribedBusinessCount

    }

    private enum CodingKeys: String, CodingKey {

        case deletedLocationsWithMediaCount = "deleted_locations_with_media_count"
        case deletedLocationsWithMediaTotalMedia = "deleted_locations_with_media_total_media"
        case deletedLocationsWithMedia = "deleted_locations_with_media"
        case cancelledSubscriptionsCount = "cancelled_subscriptions_count"
        case tierUpdateScheduleCount = "tier_update_schedule_count"
        case downgradesInScheduleCount = "downgrades_in_schedule_count"
        case tierUpdateSchedule = "tier_update_schedule"
        case subscribedBusinessCount = "subscribed_business_count"

    }

}

struct CompanyDeletedLocationWithMedia: Equatable,
                                       Hashable,
                                       Codable {

    let businessId: String
    let businessName: String
    let locationId: String
    let locationName: String
    let deletedAt: String?
    let mediaCount: Int

    init(businessId: String,
         businessName: String,
         locationId: String,
         locationName: String,
         deletedAt: String?,
         mediaCount: Int) {

        self.businessId = businessId
        self.businessName = businessName
        self.locationId = locationId
        self.locationName = locationName
        self.deletedAt = deletedAt
        self.mediaCount = mediaCount

    }

    private enum CodingKeys: String, CodingKey {

        case businessId = "business_id"
        case businessName = "business_name"
        case locationId = "location_id"
        case locationName = "location_name"
        case deletedAt = "deleted_at"
        case mediaCount = "media_count"

    }

}

struct CompanySubscriptionData: Equatable,
                               Hashable,
                               Codable {

    let businessId: String
    let businessName: String
    let ownerId: String
    let ownerName: String
    let ownerEmail: String
    let monthsSubscribed: Int
    let subscriptionId: String
    let createdAt: String

    init(businessId: String,
         businessName: String,
         ownerId: String,
         ownerName: String,
         ownerEmail: String,
         monthsSubscribed: Int,
         subscriptionId: String,
         createdAt: String) {

        self.businessId = businessId
        self.businessName = businessName
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.monthsSubscribed = monthsSubscribed
        self.subscriptionId = subscriptionId
        self.createdAt = createdAt

    }

    private enum CodingKeys: String, CodingKey {

        case businessId = "business_id"
        case businessName = "business_name"
        case ownerId = "owner_id"
        case ownerName = "owner_name"
        case ownerEmail = "owner_email"
        case monthsSubscribed = "months_subscribed"
        case subscriptionId = "subscription_id"
        case createdAt = "created_at"

    }

}

// MARK: - Growth

enum CompanyStatInterval: String,
                          Equatable,
                          Codable,
                          CaseIterable,
                          Selectable {
    
    var id: String {
        return self.description
    }

    case days7 = "7d"
    case days30 = "30d"
    case days90 = "90d"
    case days180 = "180d"
    case days365 = "365d"
    
    var description: String {
        return self.rawValue
    }

}

struct CompanyGrowthMetric: Equatable,
                            Hashable,
                            Codable {

    let added: Int
    let pctOfTotal: Double?

    init(added: Int,
         pctOfTotal: Double?) {

        self.added = added
        self.pctOfTotal = pctOfTotal

    }

    private enum CodingKeys: String, CodingKey {

        case added
        case pctOfTotal = "pct_of_total"

    }

}

struct CompanyGrowth: Equatable,
                     Hashable,
                     Codable {

    let interval: CompanyStatInterval
    let users: CompanyGrowthMetric
    let businesses: CompanyGrowthMetric
    let clients: CompanyGrowthMetric
    let media: CompanyGrowthMetric
    let subscriptions: CompanyGrowthMetric

    init(interval: CompanyStatInterval,
         users: CompanyGrowthMetric,
         businesses: CompanyGrowthMetric,
         clients: CompanyGrowthMetric,
         media: CompanyGrowthMetric,
         subscriptions: CompanyGrowthMetric) {

        self.interval = interval
        self.users = users
        self.businesses = businesses
        self.clients = clients
        self.media = media
        self.subscriptions = subscriptions

    }

}
