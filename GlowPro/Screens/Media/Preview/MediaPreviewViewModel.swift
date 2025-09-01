//
//  MediaPreviewViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/31/25.
//

import Combine
import Foundation

final class MediaPreviewViewModel: ViewModel {
    
    internal let loggerName: String = "MEDIA_PREVIEW_VIEW_MODEL"
    internal let loggerEmoji: String = "📸"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    @Published private(set) var media: [Media] = []
    @Published var selectedMedia: Media?
    private(set) var selectedMediaId: String = ""

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    var isSingleMedia: Bool {
        self.media.count == 1
    }
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(selectedMedia: Media?,
               media: [Media]) -> Self {
        
        self.selectedMedia = selectedMedia ?? media.first
        self.selectedMediaId = selectedMedia?.id ?? ""
        self.media = media
        
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func select(media: Media) {
        
        self.selectedMedia = media
        self.selectedMediaId = media.id
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension MediaPreviewViewModel {
    
    func track() {
        self.analyticsService.track(screen: .media(.preview))
    }
    
}
