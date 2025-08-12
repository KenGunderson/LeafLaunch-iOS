//
//  OnboardingViewModel.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/19/24.
//

import Combine
import SwiftUI

final class OnboardingViewModel: ViewModel {
    
    internal let loggerName: String = "ONBOARDING_VIEW_MODEL"
    internal let loggerEmoji: String = "🛹"
    
    private var navigationService: NavigationService?
    
    private let analyticsService: AnalyticsServiceProtocol
    private(set) var permissionService: PermissionsServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published var currentPageIndex: Int = 0
    
    var pages: [OnboardingPage] = []
    
    @Published var currentPage: OnboardingPage!
    
    var didAcknowledgePermissions: Bool {
        return !self.permissionService.shouldShowPermissionView
    }
    
    var progress: CGFloat {
        return CGFloat(Double(self.currentPageIndex + 1) / Double(self.pages.count))
    }
    
    var formattedProgress: String {
        return "\(self.currentPageIndex + 1)/\(self.pages.count)"
    }
    
    var formattedProgressPercentage: String {
        return formatProgress()
    }
    
    var isFirstPage: Bool {
        self.currentPageIndex == 0
    }
    
    var isLastPage: Bool {
        self.currentPageIndex == self.pages.count - 1
    }
    
    private var cancelBag: CancelBag!
    
    init(analyticsService: AnalyticsServiceProtocol,
         permissionService: PermissionsServiceProtocol,
         alertService: AlertServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        self.alertService = alertService
        self.permissionService = permissionService
        
        self.logInit()
        bindSubscribers()
        
    }
    
    deinit {
        
        self.logDeinit()
        
    }
    
    @discardableResult
    func setup(pages: [OnboardingPage]) -> Self {
        
        self.pages = pages
        self.currentPage = pages.first ?? .welcome
        
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func nextPage() {
        
        if self.pages.indices.contains(self.currentPageIndex + 1) {
            
            let nextPage = self.pages[self.currentPageIndex + 1]
            self.currentPageIndex += 1
            
            switch nextPage {
            case .welcome: self.navigationService?.push(.onboarding(.welcome))
            case .captureProgress: self.navigationService?.push(.onboarding(.captureProgress))
            case .compareResults: self.navigationService?.push(.onboarding(.compareResults))
            case .shareGrow: self.navigationService?.push(.onboarding(.shareGrow))
            case .permission: self.navigationService?.push(.onboarding(.permission))
            }
            
        }
                    
    }
    
    func findNavigationRouteIndex(routes: [Route]) {
                
        if routes.isEmpty {
            
            self.currentPage = .welcome
            self.currentPageIndex = self.pages.firstIndex(of: .welcome) ?? 0
            return
            
        }
        
        guard let latestRoute = routes.last else { return }
                
        switch latestRoute {
        case .onboarding(let route):
            
            switch route {
            case .welcome:
                
                self.currentPage = .welcome
                self.currentPageIndex = self.pages.firstIndex(of: .welcome) ?? 0
                
            case .captureProgress:
                
                self.currentPage = .captureProgress
                self.currentPageIndex = self.pages.firstIndex(of: .captureProgress) ?? 0
                
            case .compareResults:
                
                self.currentPage = .compareResults
                self.currentPageIndex = self.pages.firstIndex(of: .compareResults) ?? 0
                
            case .shareGrow:
                
                self.currentPage = .shareGrow
                self.currentPageIndex = self.pages.firstIndex(of: .shareGrow) ?? 0
                
            case .permission:
                
                self.currentPage = .permission
                self.currentPageIndex = self.pages.firstIndex(of: .permission) ?? 0
            }
            
        default: return
        }
        
    }
    
    func finish() {
        
        self.logger.debug("Finished Onboarding")
        
        self.userDefaultsService
            .set(didCompleteOnboarding: true)
        
    }
    
    private func formatProgress() -> String {
        
        let updatedProgress = CGFloat(Double(self.currentPageIndex + 1) / Double(self.pages.count))
        let formatter = FloatingPointFormatStyle<Double>.Percent.percent
        let formattedProgress = formatter.precision(.fractionLength(0))
        return updatedProgress.formatted(formattedProgress)
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension OnboardingViewModel {
    
    func track() {
        self.analyticsService.track(screen: .onboarding(.onboarding))
    }
    
}
