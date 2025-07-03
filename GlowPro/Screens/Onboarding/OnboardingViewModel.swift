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
    
    private let analyticsService: AnalyticsServiceProtocol
    private(set) var permissionService: PermissionsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    @Published var currentPageIndex: Int = 0
    
    var pages: [OnboardingPage] = []
    
    @Published var currentPage: OnboardingPage = .welcome
    
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
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
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
        return self
        
    }
    
    func nextPage() {
        
        guard !self.isLastPage else { return }
        
        self.currentPageIndex += 1
        
        self.logger.debug("Next Page")
        
    }
    
    func previousPage() {
        
        guard !self.isFirstPage else { return }
        
        self.currentPageIndex -= 1
        
        self.logger.debug("Previous Page")

    }
    
    func finish() {
        
        self.logger.debug("Finished Onboarding")
        
        self.userDefaultsService
            .set(didCompleteOnboarding: true)
        
    }
    
    func onPageAppear(_ page: OnboardingPage) {}
    func onPageDisappear(_ page: OnboardingPage) {}
    
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
        self.analyticsService.track(screen: .onboarding(.appOverview))
    }
    
}
