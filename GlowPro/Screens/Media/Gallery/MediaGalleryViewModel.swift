//
//  MediaGalleryViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import Foundation

final class MediaGalleryViewModel: ViewModel {
    
    struct GroupedMedia {
        
        let id: String
        let title: String
        let media: [Media]
        
    }
    
    enum Context: Hashable {
        
        case business(businessId: String)
        case location(locationId: String)
        case client(clientId: String)
        
    }
    
    internal let loggerName: String = "MEDIA_GALLERY_VIEW_MODEL"
    internal let loggerEmoji: String = "📸"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var groups: [GroupedMedia] = []
    @Published private(set) var shouldShowEmptyState: Bool = false
    
    private var media: [Media] = []
    
    private var context: Context!

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(context: Context) -> Self {
        
        self.context = context
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
                
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                var media: [Media] = []
                
                switch self.context! {
                case .business(let businessId):
                    media = try await self.apiService.getMedia(businessId: businessId)
                case .location(let locationId):
                    media = try await self.apiService.getMedia(locationId: locationId)
                case .client(let clientId):
                    media = try await self.apiService.getMedia(clientId: clientId)
                }
                
                let groupedMedia = self.groupedByMonth(media: media)
                
                await MainActor.run { [weak self, media] in
                    
                    self?.groups = groupedMedia
                    self?.shouldShowEmptyState = media.isEmpty
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Error.fetchErrorMessage("business details"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func emptyStateConfig() -> EmptyStateConfig {
        
        return .init(
            title: "No Photos Found",
            message: "Take your first photo. Don't forget to tag 'em!",
            image: .systemImage("magnifyingglass"),
            actionTitle: "Take Your First Photo",
            action: {
                
                // TODO: - Pop & Go To Camera
                
            }
        )
        
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

    private func groupedByMonth(media: [Media], calendar: Calendar = .current) -> [GroupedMedia] {
        
        typealias Keyed = (key: String, year: Int, month: Int, item: Media)
        
        let keyed: [Keyed] = media.compactMap { m in
            
            guard let d = m.createdAt,
                  let (y, mo) = monthComponents(from: d, calendar: calendar) else { return nil }
            
            return (monthKey(year: y, month: mo), y, mo, m)
            
        }

        // 2) Group by stable key
        let buckets = Dictionary(grouping: keyed, by: { $0.key })

        // 3) Build sections (sorted newest-first inside each)
        var sections: [GroupedMedia] = []
        sections.reserveCapacity(buckets.count)

        for (_, group) in buckets {
            
            guard let any = group.first else { continue }
            
            let title = monthTitle(year: any.year, month: any.month, calendar: calendar)
            
            let items = group
                .map { $0.item }
                .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }

            sections.append(.init(
                id: any.key,
                title: title,
                media: items
            ))
            
        }

        // 4) Sort sections by key (newest first)
        return sections.sorted { $0.id > $1.id }
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension MediaGalleryViewModel {
    
    func track() {
        self.analyticsService.track(screen: .media(.gallery))
    }
    
}
