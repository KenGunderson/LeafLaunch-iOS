//
//  MediaGalleryViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import Foundation

final class MediaGalleryViewModel: ViewModel {
    
    struct GroupedMedia: Equatable {
        
        let id: String = UUID().uuidString
        let mediaKey: String
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
    @Published private(set) var showFilters: Bool = false
    
    @Published var showSortingDropdown: Bool = false
    @Published var selectedSortingOption: MediaSortingOption? = .newest
    @Published var selectedTags: [MediaTag] = []
    
    private var media: [Media] = []
    private(set) var mediaTags: [MediaTag] = []
    
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
        self.bindSubscribers()
        
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
    
    func set(showFilters: Bool) {
        self.showFilters = showFilters
    }
    
    func set(tag: MediaTag) {
        
        if self.selectedTags.contains(tag) {
            self.selectedTags.removeAll { $0 == tag }
        }
        else {
            self.selectedTags.append(tag)
        }
        
    }
    
    func loadData() {
                
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                var media: [Media] = []
                
                switch self.context! {
                case .business(let businessId):
                    
                    media = try await self.apiService.getMedia(
                        businessId: businessId,
                        sortingOption: self.selectedSortingOption,
                        tags: self.selectedTags
                    )
                    
                case .location(let locationId):
                    
                    media = try await self.apiService.getMedia(
                        locationId: locationId,
                        sortingOption: self.selectedSortingOption,
                        tags: self.selectedTags
                    )
                    
                case .client(let clientId):
                    
                    media = try await self.apiService.getMedia(
                        clientId: clientId,
                        sortingOption: self.selectedSortingOption,
                        tags: self.selectedTags
                    )
                }
                
                let mediaTags = try await self.apiService.getMediaTags()
                
                let groupedMedia = self.groupedByMonth(media: media)
                
                await MainActor.run { [weak self, media] in
                    
                    self?.media = media
                    self?.groups = groupedMedia
                    self?.shouldShowEmptyState = media.isEmpty
                    self?.mediaTags = mediaTags
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Error.errorMessage("business details"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func select(_ selectedMedia: Media) {
        
        self.navigationService?
            .push(.media(.preview(
                selectedMedia: selectedMedia,
                media: self.media)
            ))
        
    }
    
    func emptyStateConfig() -> EmptyStateConfig {
                
        return .init(
            title: "No Photos Found",
            message: "Add a photo or adjust your filters to see results.",
            image: .systemImage("magnifyingglass"),
            actionTitle: "Take A Photo",
            action: {
                self.navigationService?.swap(.onboarding(.beforeAndAfter))
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
                .sorted {
                
                    switch self.selectedSortingOption {
                    case .oldest: return ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast)
                    default: return ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
                    }
                    
                }

            sections.append(.init(
                mediaKey: any.key,
                title: title,
                media: items
            ))
            
        }

        // 4) Sort sections by key (newest first)
        return sections.sorted {
            
            switch self.selectedSortingOption {
            case .oldest: return ($0.mediaKey < $1.mediaKey)
            default: return ($0.mediaKey > $1.mediaKey)
            }
            
        }
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.$selectedSortingOption
            .receiveOnMain()
            .dropFirst()
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &self.cancelBag)
        
        self.$selectedTags
            .receiveOnMain()
            .dropFirst()
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &self.cancelBag)
        
    }
    
}

extension MediaGalleryViewModel {
    
    func track() {
        self.analyticsService.track(screen: .media(.gallery))
    }
    
}
