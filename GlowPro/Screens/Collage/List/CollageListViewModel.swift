//
//  CollageListViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/18/25.
//

import Foundation

final class CollageListViewModel: ViewModel {
    
    struct GroupedCollages: Equatable {
        
        let id: String = UUID().uuidString
        let collageKey: String
        let title: String
        let collages: [Collage]
        
    }
    
    internal let loggerName: String = "COLLAGE_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "🎞️"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var groupedCollages: [GroupedCollages] = []
    @Published private var collages: [Collage] = []
    @Published private(set) var shouldShowEmptyState: Bool = false
    
    private(set) var context: MediaContext!
    
    var allowsCollageCreation: Bool {
        switch self.context! {
        case .business: false
        case .location: false
        case .client: true
        case .employee: false
        }
    }
    
    var clientId: String {
        switch self.context! {
        case .business: return ""
        case .location: return ""
        case .client(let clientId): return clientId
        case .employee: return ""
        }
    }
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        
        self.logInit()
        self.bindSubscribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(context: MediaContext) -> Self {
        
        self.context = context
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData(showHud: Bool = true) {
        
        if showHud {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }
        
        Task {
            
            do {
                
                var collages: [Collage] = []
                
                switch self.context! {
                case .business(let businessId):
                    
                    collages = try await self.apiService.getCollage(businessId: businessId)
                    
                case .location(let locationId):
                
                    collages = try await self.apiService.getCollage(locationId: locationId)
                    
                case .client(let clientId):
                    
                    collages = try await self.apiService.getCollage(clientId: clientId)
                    
                case .employee:
                    collages = []
                }
                
                let groupedMedia = self.groupedByMonth(collages: collages)
                
                await MainActor.run { [weak self, collages] in
                    
                    self?.collages = collages
                    self?.groupedCollages = groupedMedia
                    self?.shouldShowEmptyState = collages.isEmpty
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("collages"),
                            action: {
                                
                                self.navigationService?
                                    .popWithDelay()
                                
                            })
                    ))
                )
                
            }
            
            if showHud {
                
                self.alertService
                    .dismissLoadingIndicator()
                
            }
            
        }
        
    }
    
    func selectCollage(_ client: Client) {
        
        // TODO: - IMPLEMENT
        
//        self.navigationService?
//            .push(.client(.clientHome(clientId: client.id)))
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func emptyStateConfig() -> EmptyStateConfig {
        
        return .init(
            title: "No Collages Found",
            message: "Collages are a great way to organize your photos. Click the button below to add your first one.",
            image: .systemImage("magnifyingglass"),
            actionTitle: "Add Your First Collage",
            action: { [weak self] in
                
                // TODO: later
                
//                self?.navigationService?
//                    .push(
//                        .note(.noteCreateEdit(
//                            context: .create,
//                            clientId: self?.clientId ?? ""
//                        ))
//                    )
                
            })
        
    }
    
    private func monthComponents(from date: Date,
                                 calendar: Calendar) -> (year: Int, month: Int)? {
        
        let comps = calendar.dateComponents([.year, .month], from: date)
        
        if let year = comps.year,
           let month = comps.month {
            
            return (year, month)
        }
        
        return nil
        
    }

    private func monthKey(year: Int,
                          month: Int) -> String {
        
        String(format: "%04d-%02d", year, month) // e.g., "2025-01"
        
    }

    private func monthTitle(year: Int,
                            month: Int,
                            calendar: Calendar) -> String {
        
        var c = DateComponents()
        c.year = year
        c.month = month
        
        let date = calendar.date(from: c) ?? .distantPast
        return date.formatted(.dateTime.month(.abbreviated).year()) // "Jan 2025"
        
    }

    private func groupedByMonth(collages: [Collage], calendar: Calendar = .current) -> [GroupedCollages] {
        
        typealias Keyed = (key: String, year: Int, month: Int, item: Collage)
        
        let keyed: [Keyed] = collages.compactMap { m in
            
            guard let d = m.createdAt,
                  let (y, mo) = monthComponents(from: d, calendar: calendar) else { return nil }
            
            return (monthKey(year: y, month: mo), y, mo, m)
            
        }

        // 2) Group by stable key
        let buckets = Dictionary(grouping: keyed, by: { $0.key })

        // 3) Build sections (sorted newest-first inside each)
        var sections: [GroupedCollages] = []
        sections.reserveCapacity(buckets.count)

        for (_, group) in buckets {
            
            guard let any = group.first else { continue }
            
            let title = monthTitle(year: any.year, month: any.month, calendar: calendar)
            
            let items = group
                .map { $0.item }
                .sorted { return ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }

            sections.append(.init(
                collageKey: any.key,
                title: title,
                collages: items
            ))
            
        }

        return sections.sorted { return ($0.collageKey > $1.collageKey) }
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.viewLifecycleService
            .publisher(for: .collageList)
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.loadData(showHud: false)
            }
            .store(in: &self.cancelBag)
        
    }
    
}

extension CollageListViewModel {
    
    func track() {
        self.analyticsService.track(screen: .collage(.collageList))
    }
    
}
