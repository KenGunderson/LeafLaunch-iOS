//
//  MediaGalleryViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import Foundation

enum MediaContext: Hashable {
    
    case business(businessId: String)
    case location(locationId: String)
    case client(clientId: String)
    case employee(employeeId: String)
    
    var allowsCameraCapability: Bool {
        switch self {
        case .business: false
        case .location: true
        case .client: true
        case .employee: false
        }
    }
    
}

enum MediaSelectionContext: Hashable {
    
    case singleSelection(completion: (Media?) -> Void)
    case preview
    
    static func == (lhs: MediaSelectionContext, rhs: MediaSelectionContext) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .preview: hasher.combine("preview")
        case .singleSelection: hasher.combine("singleSelection")
        }
    }
    
}

final class MediaGalleryViewModel: ViewModel {
    
    struct GroupedMedia: Equatable {
        
        let id: String = UUID().uuidString
        let mediaKey: String
        let title: String
        let media: [Media]
        
    }
    
    internal let loggerName: String = "MEDIA_GALLERY_VIEW_MODEL"
    internal let loggerEmoji: String = "📸"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published private(set) var groups: [GroupedMedia] = []
    @Published private(set) var shouldShowEmptyState: Bool = false
    @Published private(set) var showFilters: Bool = false
    
    @Published var showSortingDropdown: Bool = false
    @Published var selectedSortingOption: MediaSortingOption? = .newest
    @Published var selectedTags: [MediaTag] = []
    
    private var media: [Media] = []
    private(set) var mediaTags: [MediaTag] = []
    
    private var mediaContext: MediaContext!
    private var mediaSelectionContext: MediaSelectionContext!

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        self.bindSubscribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(mediaContext: MediaContext,
               mediaSelectionContext: MediaSelectionContext) -> Self {
        
        self.mediaContext = mediaContext
        self.mediaSelectionContext = mediaSelectionContext
        
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
                
                switch self.mediaContext! {
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
                    
                case .employee(let employeeId):
                    
                    media = try await self.apiService.getMedia(
                        authorId: employeeId,
                        sortingOption: self.selectedSortingOption,
                        tags: self.selectedTags
                    )
                }
                
                let mediaTags = try await self.apiService
                    .getMediaTags(businessId: self.activeDestinationService.businessId ?? "")
                
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
                            message: Constants.Message.errorMessage("business details"),
                            action: {
                                
                                self.navigationService?
                                    .pop()
                                
                            })
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func select(_ selectedMedia: Media) {
        
        switch self.mediaSelectionContext! {
        case .singleSelection(let completion):
            
            completion(selectedMedia)
            self.navigationService?.pop()
            
        case .preview:
            
            self.navigationService?
                .push(.media(.preview(
                    selectedMedia: selectedMedia,
                    media: self.media)
                ))
            
        }
        
    }
    
    func emptyStateConfig() -> EmptyStateConfig {
        
        let shouldShowAction = self.mediaContext.allowsCameraCapability
        let actionTitle: String? = shouldShowAction ? "Take A Photo" : nil
        let action: (() -> Void)? = shouldShowAction ? {
        
            self.navigationService?
                .push(.media(.camera(
                    context: self.mediaContext,
                    mode: .multiple([]))
                ))
            
        } : nil
                
        return .init(
            title: "No Photos Found",
            message: "Add a photo or adjust your filters to see results.",
            image: .systemImage("magnifyingglass"),
            actionTitle: actionTitle,
            action: action
            
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
