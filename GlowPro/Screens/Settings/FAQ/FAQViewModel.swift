//
//  FAQViewModel.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 1/23/25.
//

import SwiftUI
import Combine

final class FAQViewModel: ViewModel {
    
    internal let loggerName: String = "FAQ_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"
    
    struct FAQItemSection: Codable, Hashable {
        
        struct FAQItem: Codable, Hashable {
            
            let question: String
            let answer: String
            
        }
        
        let title: String
        let sections: [FAQItem]
        
    }
    
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    
    private var cancelBag: CancelBag!
    
    @Published private(set) var faqItems: [FAQItemSection] = []
    
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.authService = authService
        self.alertService = alertService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let faq = try await self.apiService
                    .getFrequentlyAskedQuestions()
                
                await MainActor.run { [weak self] in
                    self?.faqItems = faq
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while fetching our frequently asked questions. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension FAQViewModel {
    
    func track() {
        self.analyticsService.track(screen: .settings(.faq))
    }
    
}
