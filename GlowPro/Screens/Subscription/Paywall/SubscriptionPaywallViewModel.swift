//
//  SubscriptionPaywallViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/23/25.
//

import Foundation
import SwiftUI

final class SubscriptionPaywallViewModel: ViewModel {
    
    internal let loggerName: String = "PAYWALL_VIEW_MODEL"
    internal let loggerEmoji: String = "👮🏻‍♂️"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    @Published private(set) var shouldDismiss: Bool = false
    
    @Published private(set) var paywallItem: SubscriptionPaywallItem!
    @Published private(set) var extractedColors: [Color] = []
        
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.activeDestinationService = activeDestinationService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(paywallItem: SubscriptionPaywallItem) -> Self {
        
        self.paywallItem = paywallItem
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        extractColor()
    }
    
    func subscribe() {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: "Coming Soon 🥳",
                message: "You’re looking at a sneak-peek of the paywall! The full feature is in beta and will be live soon — stay tuned.",
                primaryButtonTitle: "Okay",
                primaryButtonAction: {}
            ))))
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
    
    private func extractColor() {
        
        Task(priority: .userInitiated) {
            
            do {
                
                switch self.paywallItem.illustration {
                case .image(let image, _):
                    
                    let image = UIImage(resource: image)
                    
                    let uiColors = try image.extractColors(
                        numberOfColors: 2,
                        sortByProminence: true
                    )
                    
                    let swiftUIColors = uiColors.map { Color($0) }
                    
                    await MainActor.run { [weak self] in
                        self?.extractedColors = swiftUIColors
                    }
                    
                default: break
                }
                
            } catch {
                print("Failed to extract colors:", error)
            }
            
        }
        
    }
    
}

extension SubscriptionPaywallViewModel {
    
    func track() {
        self.analyticsService.track(screen: .subscription(.paywall))
    }
    
}
