//
//  MediaGalleryViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import Foundation
import _PhotosUI_SwiftUI
import Combine

enum MediaContext: Hashable, Sendable {

    case business(businessId: String)
    case location(locationId: String)
    case client(clientId: String)
    case employee(employeeId: String)

    var allowsCameraCapability: Bool {
        switch self {
        case .business: false
        case .location: false
        case .client: true
        case .employee: false
        }
    }

    var allowsCollageCapability: Bool {
        switch self {
        case .business: false
        case .location: false
        case .client: true
        case .employee: false
        }
    }

    var clientId: String? {
        switch self {
        case .business: return nil
        case .location: return nil
        case .client(clientId: let clientId): return clientId
        case .employee: return nil
        }
    }

    var analyticsName: String {
        switch self {
        case .business: return "business"
        case .location: return "location"
        case .employee: return "employee"
        case .client: return "client"
        }
    }

}

enum MediaSelectionContext: Hashable, Sendable {

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
    private let viewLifecycleService: ViewLifecycleServiceProtocol

    @Published private(set) var groups: [GroupedMedia] = []
    @Published private(set) var shouldShowEmptyState: Bool = false
    
    @Published private(set) var isFirstLoad: Bool = true

    @Published private(set) var isEditMode: Bool = false
    @Published private(set) var editingMedia: [Media] = []

    @Published var showSortingDropdown: Bool = false
    @Published var selectedSortingOption: MediaSortingOption? = .newest
    @Published var selectedTags: [MediaTag] = []

    @Published var selectedPhotoPickerItems: [PhotosPickerItem] = []

    @Published var shouldShowMediaSourceSelectionSheet: Bool = false
    @Published var shouldShowApplePhotosSelectionSheet: Bool = false

    private var media: [Media] = []
    private(set) var mediaTags: [MediaTag] = []

    private(set) var mediaContext: MediaContext!
    private var mediaSelectionContext: MediaSelectionContext!
    private(set) var mediaFilterOptions: MediaType!

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    private var loadTask: Task<Void, Never>?

    // Section windowing
    private var allGroups: [GroupedMedia] = []
    private var nextGroupStartIndex: Int = 0
    private let sectionPageSize: Int = 3
    
    private var isLoading: Bool = false
    private var isPagingComplete: Bool = false

    var navTitle: String {
        self.mediaFilterOptions == .collage ? "Collages" : "Media Gallery"
    }

    var shouldShowPlusButton: Bool {
        return self.mediaContext.allowsCameraCapability || self.mediaContext.allowsCollageCapability
    }
    
    var allowsDelete: Bool {
        return self.isEditMode && self.activeDestinationService.isOwnerOrManager
    }

    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {

        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
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
    func setup(mediaContext: MediaContext,
               mediaSelectionContext: MediaSelectionContext,
               mediaFilterOptions: MediaType = .image) -> Self {

        self.mediaContext = mediaContext
        self.mediaSelectionContext = mediaSelectionContext
        self.mediaFilterOptions = mediaFilterOptions

        return self

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func set(tag: MediaTag) {

        if self.selectedTags.contains(tag) {
            self.selectedTags.removeAll { $0 == tag }
        }
        else {
            self.selectedTags.append(tag)
        }

    }

    func loadData(showHud: Bool = true) {
        
        guard !self.isLoading else { return }
        guard !self.isPagingComplete else { return }
        
        // Cancel any in-flight load
        self.loadTask?.cancel()
        
        if showHud {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }

        let currentContext = self.mediaContext!
        let currentSorting = self.selectedSortingOption
        let currentFilter = self.mediaFilterOptions
        let currentTags = self.selectedTags

        self.loadTask = Task { [weak self] in
            
            guard let self else { return }

            do {
                
                let query = Query(
                    limit: Query.defaultLimit,
                    offset: self.media.count
                )
                
                let onlyShowUntagged = (self.selectedSortingOption == .onlyUntagged)
                
                var media: [Media] = []

                switch currentContext {
                case .business(let businessId):
                    
                    media = try await self.apiService.getMedia(
                        businessId: businessId,
                        sortingOption: currentSorting,
                        filterOption: currentFilter,
                        tags: currentTags,
                        onlyUntagged: onlyShowUntagged,
                        query: query
                    )
                    
                case .location(let locationId):
                    
                    media = try await self.apiService.getMedia(
                        locationId: locationId,
                        sortingOption: currentSorting,
                        filterOption: currentFilter,
                        tags: currentTags,
                        onlyUntagged: onlyShowUntagged,
                        query: query
                    )
                    
                case .client(let clientId):
                    
                    media = try await self.apiService.getMedia(
                        clientId: clientId,
                        sortingOption: currentSorting,
                        filterOption: currentFilter,
                        tags: currentTags,
                        onlyUntagged: onlyShowUntagged,
                        query: query
                    )
                    
                case .employee(let employeeId):
                    
                    media = try await self.apiService.getMedia(
                        authorId: employeeId,
                        sortingOption: currentSorting,
                        filterOption: currentFilter,
                        tags: currentTags,
                        query: query
                    )
                }

                if Task.isCancelled { return }

                let mediaTags = try await self.apiService
                    .getMediaTags(businessId: self.activeDestinationService.businessId ?? "")

                if Task.isCancelled { return }

                // Build all groups once, then present a windowed subset
                let all = self.groupedByMonth(media: media)

                await MainActor.run { [weak self, media] in
                    
                    guard let self else { return }

                    self.media = media
                    self.allGroups = all
                    self.nextGroupStartIndex = 0

                    // Seed first window
                    let end = min(self.sectionPageSize, self.allGroups.count)
                    self.groups = Array(self.allGroups.prefix(end))
                    self.nextGroupStartIndex = end

                    self.shouldShowEmptyState = media.isEmpty
                    self.mediaTags = mediaTags
                    self.isFirstLoad = false
                    
                    self.isPagingComplete = media.count < Query.defaultLimit
                    
                }
                
            }
            catch {
                
                if Task.isCancelled { return }

                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("media"),
                            action: {
                                self.navigationService?
                                    .popWithDelay()
                            })
                    ))
                )
            }
            
            if showHud {
                
                if !Task.isCancelled {
                    self.alertService
                        .dismissLoadingIndicator()
                }
                
            }
            
            await MainActor.run {
                self.isLoading = false
            }
            
        }

    }

    func onGroupAppear(_ appearingGroup: GroupedMedia) {
        
        guard let lastVisible = self.groups.last, lastVisible.id == appearingGroup.id else { return }
        self.loadNextSectionPageIfNeeded()
        
    }

    private func loadNextSectionPageIfNeeded() {
        
        guard self.nextGroupStartIndex < self.allGroups.count else { return }
        
        let end = min(self.nextGroupStartIndex + self.sectionPageSize, self.allGroups.count)
        let slice = self.allGroups[self.nextGroupStartIndex..<end]
        
        self.groups.append(contentsOf: slice)
        self.nextGroupStartIndex = end
        
    }

    func select(_ selectedMedia: Media) {

        if self.isEditMode {

            if self.editingMedia.contains(selectedMedia) {
                self.editingMedia.removeAll { $0 == selectedMedia }
            } else {
                self.editingMedia.append(selectedMedia)
            }

        } else {

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

    }

    func set(isEditMode: Bool) {

        self.isEditMode = isEditMode
        self.editingMedia.removeAll()

    }

    func emptyStateConfig() -> EmptyStateConfig {

        let isCollageContext = self.mediaFilterOptions == .collage
        let shouldShowAction = (self.mediaContext.allowsCameraCapability && !isCollageContext)

        let title: String = isCollageContext ? "No Collages Found" : "No Photos Found"
        let message: String = isCollageContext ? "Add a collage or adjust your filters to see results." : "Add a photo or adjust your filters to see results."
        let actionTitle: String? = shouldShowAction ? "Take A Photo" : nil
        let action: (() -> Void)? = shouldShowAction ? {

            self.navigationService?
                .push(.media(.camera(
                    context: self.mediaContext,
                    mode: .multiple([]))
                ))

        } : nil

        return .init(
            title: title,
            message: message,
            image: .systemImage("magnifyingglass"),
            actionTitle: actionTitle,
            action: action

        )

    }

    func handleSourceSelectionAction(_ source: SourceType) {

        switch source {
        case .applePhotos: self.shouldShowApplePhotosSelectionSheet = true
        case .mediaGallery: break
        case .collageGallery: break
        case .camera:

            if let clientId = self.mediaContext.clientId {

                self.navigationService?
                    .push(.media(.camera(
                        context: .client(clientId: clientId),
                        mode: .single(nil))
                    ))

            }

        }

    }

    func handlePHPickerSelectionConverionToUIImage(items: [PhotosPickerItem]) {

        // This flow is only for client
        guard let clientId = self.mediaContext.clientId else { return }

        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))

        Task {

            let locationId = self.activeDestinationService.locationEmployee?.locationId

            do {
                
                try await items.asyncForEach { item in

                    if let data = try? await item.loadTransferable(type: Data.self) {

                        if let uiImage = UIImage(data: data) {

                            let _ = try await self.apiService
                                .uploadMedia(uploadMedia: .init(
                                    data: uiImage.compressedData(maxMegaBytes: 5) ?? Data(),
                                    businessId: self.activeDestinationService.businessId,
                                    locationId: locationId,
                                    clientId: clientId
                                ))

                        }

                    }

                }
                
            } catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .create, "media"),
                            action: { })
                    ))
                )
                
            }

            self.alertService
                .dismissLoadingIndicator()

            await MainActor.run { [weak self] in

                self?.selectedPhotoPickerItems = []
                self?.resetPagingState()
                self?.loadData()

            }

        }

    }
    
    func presentDeleteMediaAlert() {
                
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: Constants.Message.deleteConfirmationTitle("Media"),
                message: Constants.Message.deleteConfirmationMessage("media"),
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    self?.deleteEditItems()
                },
                primaryButtonBackgroundColor: Style.shared.background(.error),
                primaryButtonTextColor: Style.shared.textColor(.titleInverted),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))
        
    }
    
    private func deleteEditItems() {
        
        Task {
            
            await self.editingMedia.asyncForEach { media in
                
                do {
                    
                    try await self.apiService.deleteMedia(mediaId: media.id)
                    
                }
                catch {
                    
                    self.alertService.showAlert(.init(
                        .appAlert(
                            .error(
                                message: Constants.Message.errorMessage(context: .delete, "media"),
                                action: {})
                        ))
                    )
                    
                }
                
            }
            
            await MainActor.run {
                    
                self.isEditMode = false
                self.editingMedia.removeAll()
                
            }
            
            self.resetPagingState()
            self.loadData()
            
        }
        
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
    
    func resetPagingState() {
        
        self.isLoading = false
        self.isPagingComplete = false
        
        self.groups.removeAll()
        self.media = []
        self.nextGroupStartIndex = 0
        
    }

    private func bindSubscribers() {

        self.cancelBag = CancelBag()

        self.$selectedSortingOption
            .receive(on: RunLoop.main)
            .dropFirst()
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                
                self?.resetPagingState()
                self?.loadData()
                
            }
            .store(in: &self.cancelBag)

        self.$selectedTags
            .receive(on: RunLoop.main)
            .dropFirst()
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                
                self?.resetPagingState()
                self?.loadData()
                
            }
            .store(in: &self.cancelBag)

        self.viewLifecycleService
            .publisher(for: .mediaGallery)
            .sink { [weak self] in
                
                self?.resetPagingState()
                self?.loadData()
                
            }
            .store(in: &self.cancelBag)

    }

}

extension MediaGalleryViewModel {

    func track() {

        self.analyticsService.track(screen: .media(.gallery(
            mediaType: self.mediaFilterOptions
        )))

    }

}
