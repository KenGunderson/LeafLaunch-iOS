//
//  MockModels.swift
//  LeafLaunch
//
// All mock fixtures live here. Customer-facing projection of LeafLaunch-Web's
// src/services/demo owner workspace: High Standards (Store ...0001).
// Sources: demoClientWorkspaceFixtures, demoCatalogCategoryFixtures,
// demoLocationProductFixtures, demoPromotionFixtures, demoEventFixtures,
// demoAccountDirectoryFixtures, demoLoyaltyFixtures, and their strings.ts copy.
// Random web IDs are stable here; schedules keep the same offsets from launch.

import Foundation

// Preserve the existing preview user entry point without a second fixture set.
enum MockModels {

    enum MockUser {

        static var user1: LLUser { MockCustomerModels.user }

    }

    static var allUsers: [LLUser] { [MockUser.user1] }

}

enum MockCustomerModels {

    static let primaryLocationId = "98500000-0000-4000-8000-000000000001"
    static let secondaryLocationId = "98500000-0000-4000-8000-000000000002"
    static let tertiaryLocationId = "98500000-0000-4000-8000-000000000005"
    static let externalId = "firebase-demo-customer-1"
    static let guestIdentityId = "guest:98400000-0000-4000-8000-000000000001"
    static let hostURL = "https://leaflaunch-mock.invalid"
    static let email = "alexis.mensah@example.com"
    static let sessionDate = Date()
    static let createdAt = sessionDate.addingTimeInterval(-120 * 3_600)

    static var businessId: String {
        BusinessConfig.businessId.isEmpty ? "80000000-0000-4000-8000-000000000001" : BusinessConfig.businessId
    }

    static var appKey: String {
        BusinessConfig.appKey.isEmpty ? "1f5673ac-ce3a-4f11-94a0-62b26f96fcd5" : BusinessConfig.appKey
    }

    static var bootstrap: CustomerBootstrap {

        CustomerBootstrap(
            appKey: appKey,
            storeId: businessId,
            store: store,
            publicName: "High Standards",
            state: .available,
            updateURL: nil,
            branding: StoreAppBranding(
                radius: StoreAppRadius(
                    extraSmall: 2,
                    small: 4,
                    small2: 6,
                    medium: 10,
                    medium2: 14,
                    large: 20,
                    extraLarge: 28
                )
            ),
            ageGateRequired: true,
            minimumAge: 21,
            ageGateVersion: 1,
            featureFlags: ["loyalty": true, "promotions": true, "events": true],
            locations: locations.compactMap { location in

                guard location.isAvailable else { return nil }

                return BootstrapLocation(
                    id: location.id,
                    name: location.name,
                    timezone: location.timezone ?? "America/Los_Angeles",
                    currencyCode: location.currencyCode ?? "USD",
                    countryCode: location.countryCode,
                    region: location.region,
                    agePolicy: agePolicy(for: location)
                )

            }
        )

    }

    static var store: PublicStore {

        PublicStore(
            id: businessId,
            name: "High Standards",
            legalName: "High Standards Retail LLC",
            supportEmail: nil,
            supportPhone: nil,
            websiteURL: nil
        )

    }

    static func agePolicy(for location: StoreLocation) -> EffectiveAgePolicy {

        // The demo business maintains this requirement for its locations.
        EffectiveAgePolicy(
            required: true,
            minimumAge: 21,
            countryCode: location.countryCode,
            region: location.region,
            gateVersion: 1,
            approvalRevision: 1
        )

    }

    static var account: CustomerAccount {

        CustomerAccount(
            id: "98300000-0000-4000-8000-000000000001",
            accountId: "98400000-0000-4000-8000-000000000001",
            displayName: "Alexis Mensah",
            status: .active,
            anonymizedAt: nil,
            createdAt: sessionDate.addingTimeInterval(-2 * 3_600),
            updatedAt: sessionDate.addingTimeInterval(-2 * 3_600)
        )

    }

    static var user: LLUser {
        LLUser(customerAccount: account, externalId: externalId, email: email)
    }

    static func newAccount(displayName: String) -> CustomerAccount {

        CustomerAccount(
            id: UUID().uuidString,
            accountId: UUID().uuidString,
            displayName: displayName,
            status: .active,
            anonymizedAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

    }

    static var categories: [ProductCategory] {

        let names = ["Flower", "Accessories", "Edibles"]
        let subcategories = ["Whole Flower", "Glass & Storage", "Gummies & Chocolates"]
        let packages = ["Flower Sample Jar", "Single Glass Piece", "Gummy Starter Pouch"]

        return names.enumerated().map { index, name in

            let categoryId = fixtureId("92000000", index + 1)

            return ProductCategory(
                id: categoryId,
                revision: 1,
                subcategories: [
                    ProductSubcategory(
                        id: fixtureId("a9100000", index + 1),
                        name: subcategories[index],
                        categoryId: categoryId
                    )
                ],
                pricingPresets: [
                    CategoryPricingPreset(
                        id: fixtureId("b7000000", index + 1),
                        label: packages[index],
                        unit: index == 0 ? nil : "piece",
                        quantity: index == 0 ? nil : (index == 1 ? 1 : 5)
                    )
                ],
                attributeIds: index < 2 ? ["a9300000-0000-4000-8000-000000000001"] : [],
                name: name,
                imageURL: nil,
                status: .active,
                displayOrder: index,
                createdAt: Date(timeIntervalSince1970: 1_791_115_200),
                updatedAt: Date(timeIntervalSince1970: 1_791_115_200)
            )

        }

    }

    // Keep the web catalog's ordering, classification, descriptions, and prices.
    // In particular, preserve its intentional cross-category fixture examples.
    private static let catalog: [(name: String, categoryIndex: Int, hasSubcategory: Bool, description: String?)] = [
        ("Amber Glass Storage Jar", 1, false, "Reusable glassware and storage accessories with care instructions included."),
        ("Blood Orange Gummies", 0, true, "Individually portioned sweets with ingredient and serving information on each package."),
        ("Dark Chocolate Bites", 2, true, "Individually portioned sweets with ingredient and serving information on each package."),
        ("Cooling Mint Lotion", 0, true, "Botanical skin care for everyday routines, with application instructions on the label."),
        ("Borosilicate Water Pipe", 1, true, "Reusable glassware and storage accessories with care instructions included."),
        ("Stainless Steel Grinder", 1, true, "Reusable glassware and storage accessories with care instructions included."),
        ("Sea Salt Caramels", 2, true, "Individually portioned sweets with ingredient and serving information on each package."),
        ("Cedar Reserve", 1, true, nil),
        ("Harbor House Blend", 0, true, nil),
        ("Cedar Reserve", 1, false, nil),
        ("Harbor House Blend", 0, true, nil),
        ("Cedar Reserve", 2, true, nil),
        ("Harbor House Blend", 0, true, nil),
        ("Cedar Reserve", 1, true, nil),
        ("Harbor House Blend", 1, true, nil),
        ("Cedar Reserve", 2, true, nil),
        ("Harbor House Blend", 1, true, nil),
        ("Cedar Reserve", 0, true, nil),
        ("Harbor House Blend", 1, false, nil),
        ("Cedar Reserve", 0, true, nil),
        ("Harbor House Blend", 2, true, nil),
        ("Cedar Reserve", 0, true, nil),
        ("Harbor House Blend", 1, true, nil),
        ("Cedar Reserve", 1, true, nil),
        ("Harbor House Blend", 2, true, nil),
        ("Cedar Reserve", 1, true, nil),
        ("Harbor House Blend", 0, true, nil),
        ("Cedar Reserve", 1, false, nil),
    ]

    static var products: [Product] { products(locationId: primaryLocationId) }

    static func products(locationId: String) -> [Product] {

        guard locations.contains(where: { $0.id == locationId && $0.isAvailable }) else { return [] }

        let locationIndex = locationId == primaryLocationId ? 0 : (locationId == secondaryLocationId ? 1 : 3)
        let statuses: [Product.Status] = [.draft, .published, .hidden, .temporarilyUnavailable, .archived]
        let availableCatalog = locationIndex == 0 ? catalog : Array(catalog.prefix(5))

        return availableCatalog.enumerated().compactMap { index, item in

            let status = statuses[(index + locationIndex) % statuses.count]
            guard status == .published || status == .temporarilyUnavailable else { return nil }

            let category = categories[item.categoryIndex]
            let productId = fixtureId("ad100000", index + 1)
            let listingNumber = (locationIndex + 1) * 1_000 + index + 1
            let basePrice: Decimal? = index == 0 && locationIndex == 1
                ? nil
                : Decimal(locationIndex > 0 && index.isMultiple(of: 2) ? 21 : 18) + Decimal(index) * Decimal(string: "1.25")!

            return Product(
                id: fixtureId("ad300000", listingNumber),
                storeProductId: productId,
                storeLocationId: locationId,
                displayName: item.name,
                description: item.description,
                status: status,
                publishedAt: sessionDate.addingTimeInterval(-Double(index) * 3_600),
                media: (0..<2).map { mediaIndex in

                    ProductMedia(
                        id: fixtureId("ad400000", (index + 1) * 10 + mediaIndex),
                        storeProductId: productId,
                        url: imageURL(seed: "\(productId)-\(mediaIndex)"),
                        width: 640,
                        height: 480,
                        altText: mediaIndex == 0 ? "Botanical product packaging on a studio background" : nil,
                        displayOrder: mediaIndex,
                        status: .active,
                        createdAt: createdAt,
                        updatedAt: createdAt
                    )

                },
                currencyCode: "USD",
                category: category,
                subcategory: item.hasSubcategory ? category.subcategories.first : nil,
                attributes: [],
                variants: [
                    ProductPricing(
                        id: fixtureId("ad450000", listingNumber),
                        productVariantId: fixtureId("ad200000", index + 1),
                        displayPrice: basePrice,
                        availability: status == .temporarilyUnavailable ? .temporarilyUnavailable : .available,
                        name: "Default",
                        baseDisplayPrice: basePrice,
                        promotionId: nil
                    )
                ]
            )

        }

    }

    static func imageURL(seed: String) -> URL {
        URL(string: "https://picsum.photos/seed/\(seed)/640/480")!
    }

    // Preview-only attributes leave the customer demo catalog unchanged.
    static var previewProductAttributes: [ProductAttribute] {

        [
            ProductAttribute(
                id: "preview-packaging",
                name: "Packaging",
                valueType: .text,
                value: .text("Resealable container"),
                unit: nil
            ),
            ProductAttribute(
                id: "preview-storage",
                name: "Storage",
                valueType: .text,
                value: .text("Keep in a cool, dry place"),
                unit: nil
            )
        ]

    }

    private static let locationSeeds: [(id: String, name: String, street: String, city: String, region: String, postal: String, status: StoreLocation.Status)] = [
        ("98500000-0000-4000-8000-000000000001", "Pearl District Shop", "120 Cedar Avenue", "Portland", "OR", "97205", .active),
        ("98500000-0000-4000-8000-000000000002", "Capitol Hill Storefront", "845 Summit Way", "Seattle", "WA", "98102", .pendingArchive),
        ("98500000-0000-4000-8000-000000000005", "Old Town Shop", "75 Harbor Court", "Eureka", "CA", "95501", .active),
    ]

    static var locations: [StoreLocation] {

        locationSeeds.enumerated().map { index, seed in

            StoreLocation(
                id: seed.id,
                createdAt: sessionDate.addingTimeInterval(-Double(index) * 3_600),
                updatedAt: sessionDate,
                storeId: businessId,
                name: seed.name,
                status: seed.status,
                addressLine1: seed.street,
                addressLine2: nil,
                city: seed.city,
                region: seed.region,
                postalCode: seed.postal,
                countryCode: "US",
                timezone: "America/Los_Angeles",
                currencyCode: "USD",
                archiveEffectiveAt: seed.status == .pendingArchive ? sessionDate.addingTimeInterval(14 * 86_400) : nil,
                hours: (0..<7).map { weekday in

                    StoreHours(
                        id: fixtureId("ad460000", (index + 1) * 10 + weekday),
                        storeLocationId: seed.id,
                        weekday: weekday,
                        sequence: 0,
                        opensAt: weekday == 0 ? nil : "09:00",
                        closesAt: weekday == 0 ? nil : (weekday == 5 ? "01:00" : "17:00"),
                        closed: weekday == 0,
                        createdAt: sessionDate,
                        updatedAt: sessionDate
                    )

                },
                scheduleExceptions: seed.id == primaryLocationId ? scheduleExceptions : []
            )

        }

    }

    private static var scheduleExceptions: [ScheduleException] {

        let entries: [(date: String, label: String?, sequence: Int, opens: String?, closes: String?, closed: Bool)] = [
            ("2026-12-25", "Holiday Closure", 0, nil, nil, true),
            ("2026-12-31", nil, 0, "09:00", "12:00", false),
            ("2026-12-31", nil, 2, "18:00", "01:00", false)
        ]

        return entries.enumerated().map { index, entry in

            ScheduleException(
                id: fixtureId("ad470000", index + 1),
                storeLocationId: primaryLocationId,
                localDate: entry.date,
                label: entry.label,
                sequence: entry.sequence,
                opensAt: entry.opens,
                closesAt: entry.closes,
                closed: entry.closed,
                createdAt: sessionDate,
                updatedAt: sessionDate
            )

        }

    }

    static var locationDetails: CustomerLocationDetails { locationDetails(for: primaryLocationId)! }

    static func locationDetails(for locationId: String) -> CustomerLocationDetails? {

        guard let location = locations.first(where: { $0.id == locationId && $0.isAvailable }) else { return nil }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: location.timezone ?? "America/Los_Angeles") ?? .current
        let now = Date()

        return CustomerLocationDetails(
            location: location,
            agePolicy: agePolicy(for: location),
            openNow: isOpen(location: location, at: now, calendar: calendar),
            localDate: localDate(now, calendar: calendar),
            mapsAddress: location.address
        )

    }

    private static func localDate(_ date: Date, calendar: Calendar) -> String {

        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)

    }

    private static func isOpen(location: StoreLocation, at now: Date, calendar: Calendar) -> Bool {

        let today = calendar.startOfDay(for: now)
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return false }

        for day in [yesterday, today] {

            let date = localDate(day, calendar: calendar)
            let exceptions = (location.scheduleExceptions ?? []).filter { $0.localDate == date }
            let intervals: [(String?, String?, Bool)] = exceptions.isEmpty
                ? (location.hours ?? []).filter { $0.weekday == calendar.component(.weekday, from: day) - 1 }
                .map { ($0.opensAt, $0.closesAt, $0.closed) }
                : exceptions.map { ($0.opensAt, $0.closesAt, $0.closed) }

            for (opens, closes, closed) in intervals {

                guard !closed, let opens, let closes else { continue }
                let start = opens.split(separator: ":").compactMap { Int($0) }
                let end = closes.split(separator: ":").compactMap { Int($0) }
                guard start.count == 2, end.count == 2,
                      let opening = calendar.date(bySettingHour: start[0], minute: start[1], second: 0, of: day),
                      var closing = calendar.date(bySettingHour: end[0], minute: end[1], second: 0, of: day) else { continue }

                if closing <= opening {
                    closing = calendar.date(byAdding: .day, value: 1, to: closing) ?? closing
                }

                if now >= opening && now < closing { return true }

            }

        }

        return false

    }

    static var promotions: [Promotion] { promotions(locationId: primaryLocationId) }

    static func promotions(locationId: String) -> [Promotion] {

        // The web seeds marketing content only for these ACTIVE locations.
        guard locationId == primaryLocationId || locationId == tertiaryLocationId else { return [] }
        let titles = ["Weekend Welcome", "Morning Specials", "Member Appreciation", "Seasonal Savings", "Neighborhood Spotlight", "New Arrivals", "Community Week", "Early Bird Offer"]
        let locationNumber = locationId == primaryLocationId ? 1 : 5
        let linkedProduct = products(locationId: locationId).first { $0.status == .published }

        return (0..<32).filter { $0 % 6 == 2 }.map { index in

            let id = fixtureId("ad500000", locationNumber * 100 + index + 1)
            let priceChanging = index % 4 == 2 && linkedProduct != nil
            let startsAt = sessionDate.addingTimeInterval(-24 * 3_600)
            let endsAt = sessionDate.addingTimeInterval(24 * 3_600)
            let targets: [PromotionVariantTarget]

            if priceChanging, let product = linkedProduct, let variant = product.variants.first {

                targets = [
                    PromotionVariantTarget(
                        id: fixtureId("ad510000", locationNumber * 100 + index + 1),
                        promotionId: id,
                        locationVariantListingId: variant.id,
                        discountType: .override,
                        discountValue: nil,
                        overridePrice: index == 2 ? 0 : 5,
                        basePriceSnapshot: variant.baseDisplayPrice,
                        displayNameSnapshot: product.displayName,
                        effectiveStartsAt: startsAt,
                        effectiveEndsAt: endsAt,
                        effective: false,
                        createdAt: sessionDate.addingTimeInterval(-96 * 3_600),
                        updatedAt: sessionDate.addingTimeInterval(-96 * 3_600)
                    )
                ]

            } else {
                targets = []
            }

            return Promotion(
                id: id,
                storeId: businessId,
                image: nil,
                linkedProducts: nil,
                linkedProductListingIds: priceChanging ? linkedProduct.map { [$0.id] } : [],
                title: "\(titles[index % titles.count]) \(index + 1)",
                description: index % 7 == 0 ? nil : "Visit this Location during the saved schedule. Review the recorded details before publication.",
                kind: priceChanging ? .priceOverride : .informational,
                status: .active,
                startsAt: startsAt,
                endsAt: endsAt,
                publishedAt: sessionDate.addingTimeInterval(-48 * 3_600),
                displayOrder: index,
                createdAt: sessionDate.addingTimeInterval(-Double(96 + index) * 3_600),
                updatedAt: sessionDate.addingTimeInterval(-96 * 3_600),
                locations: [
                    PromotionLocation(
                        id: fixtureId("ad520000", locationNumber * 100 + index + 1),
                        promotionId: id,
                        storeLocationId: locationId,
                        timezone: "America/Los_Angeles",
                        startsAt: startsAt,
                        endsAt: endsAt,
                        createdAt: createdAt,
                        updatedAt: createdAt
                    )
                ],
                variantTargets: targets
            )

        }

    }

    static var events: [StoreEvent] { events(locationId: primaryLocationId) }

    static func events(locationId: String) -> [StoreEvent] {

        guard locationId == primaryLocationId || locationId == tertiaryLocationId else { return [] }
        let titles = ["Community Evening", "Meet the Grower", "Product Showcase", "Neighborhood Open House", "Member Gathering", "Seasonal Preview", "Local Maker Visit", "Weekend Workshop"]
        let locationNumber = locationId == primaryLocationId ? 1 : 5

        return (0..<32).filter { $0 % 6 == 1 }.map { index in

            let id = fixtureId("ad600000", locationNumber * 100 + index + 1)
            let startsAt = sessionDate.addingTimeInterval(Double(24 + index) * 3_600)
            let endsAt = index % 7 == 0 ? nil : sessionDate.addingTimeInterval(Double(72 + index) * 3_600)

            return StoreEvent(
                id: id,
                storeId: businessId,
                image: nil,
                title: "\(titles[index % titles.count]) \(index + 1)",
                description: index % 7 == 0 ? nil : "Visit this Location during the recorded event schedule. Review all targeted Locations before publication.",
                status: .scheduled,
                startsAt: startsAt,
                endsAt: endsAt,
                publishedAt: sessionDate.addingTimeInterval(-48 * 3_600),
                externalURL: index == 1 ? URL(string: "mailto:events@example.com") : nil,
                createdAt: sessionDate.addingTimeInterval(-Double(96 + index) * 3_600),
                updatedAt: sessionDate.addingTimeInterval(-96 * 3_600),
                locations: [
                    EventLocation(
                        id: fixtureId("ad610000", locationNumber * 100 + index + 1),
                        eventId: id,
                        storeLocationId: locationId,
                        timezone: "America/Los_Angeles",
                        startsAt: startsAt,
                        endsAt: endsAt,
                        createdAt: createdAt,
                        updatedAt: createdAt
                    )
                ]
            )

        }

    }

    static var membership: CustomerLocationMembership { membership(locationId: primaryLocationId) }

    static var memberships: [String: CustomerLocationMembership] {

        Dictionary(uniqueKeysWithValues: [primaryLocationId, secondaryLocationId].map {
            ($0, membership(locationId: $0))
        })

    }

    static func membership(locationId: String,
                           customerAccount: CustomerAccount = account,
                           existingMembership: CustomerLocationMembership? = nil) -> CustomerLocationMembership {

        let isSeededCustomer = customerAccount.id == account.id
        let isSeededMembership = isSeededCustomer && (locationId == primaryLocationId || locationId == secondaryLocationId)
        let membershipIndex = locationId == primaryLocationId ? 1 : (locationId == secondaryLocationId ? 9 : 14)
        let joinedAt = existingMembership?.joinedAt
            ?? (isSeededMembership ? createdAt.addingTimeInterval(locationId == secondaryLocationId ? -20 * 3_600 : 0) : Date())

        return CustomerLocationMembership(
            id: existingMembership?.id ?? (isSeededCustomer ? fixtureId("98600000", membershipIndex) : UUID().uuidString),
            loyaltyAccountId: existingMembership?.loyaltyAccountId
                ?? (isSeededCustomer ? "98650000-0000-4000-8000-000000000001" : customerAccount.accountId),
            customerAccountId: customerAccount.id,
            storeLocationId: locationId,
            membershipCode: isSeededCustomer ? "LEAF2345" : "NEWC2345",
            status: .active,
            cachedPointsBalance: isSeededCustomer ? "1235" : "0",
            joinedAt: joinedAt,
            leftAt: nil,
            createdAt: existingMembership?.createdAt ?? joinedAt,
            updatedAt: existingMembership?.updatedAt ?? (isSeededMembership ? sessionDate.addingTimeInterval(-3_600) : Date()),
            notificationPreference: nil,
            customerDisplayName: customerAccount.displayName
        )

    }

    static var loyaltyHistory: [LoyaltyHistoryEntry] {

        let entries: [(LoyaltyHistoryEntry.EntryType, String, String, String?)] = [
            (.award, "1000", "Points earned for a completed purchase.", nil),
            (.redemption, "-100", "Member reward redeemed.", "Member Appreciation Reward"),
            (.correction, "-25", "Purchase points corrected.", nil),
            (.reversal, "100", "Reward redemption reversed.", "Member Appreciation Reward")
        ] + Array(repeating: (.award, "10", "Points earned for a completed purchase.", nil), count: 26)

        return entries.enumerated().map { index, entry in

            LoyaltyHistoryEntry(
                id: fixtureId("98800000", index + 1),
                entryType: entry.0,
                pointsDelta: entry.1,
                customerReason: entry.2,
                rewardTitleSnapshot: entry.3,
                createdAt: sessionDate.addingTimeInterval(-Double(69 - index) * 3_600)
            )

        }.sorted { $0.createdAt > $1.createdAt }

    }

    private static func fixtureId(_ prefix: String, _ index: Int) -> String {
        "\(prefix)-0000-4000-8000-\(String(format: "%012d", index))"
    }

}
