//
//  SubscriptionPaywallViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/23/25.
//

import Foundation

final class SubscriptionPaywallViewModel: ViewModel {
    
    enum SubscriptionBenefit: String,
                              CaseIterable {

        case imagesPerMonth
        case unlimitedLocations
        case unlimitedTeamInvites
        case customSecuritySettings
        case hipaaCompliantStorage
        case prioritySupport

        var title: String {
            switch self {
            case .imagesPerMonth: return "1,500 Images Per Month"
            case .unlimitedLocations: return "Unlimited Locations"
            case .unlimitedTeamInvites: return "Unlimited Team Invites"
            case .customSecuritySettings: return "Custom Security Settings"
            case .hipaaCompliantStorage: return "HIPPA-Compliant Storage"
            case .prioritySupport: return "Priority Support"
            }
        }

        var message: String {
            switch self {
            case .imagesPerMonth: return "Capture up to 1,500 high-quality images every month without interruption."
            case .unlimitedLocations: return "Use GlowPro across any number of business locations—no limits, no add-ons."
            case .unlimitedTeamInvites: return "Invite your entire staff to collaborate with full access included."
            case .customSecuritySettings: return "Control access, roles, and visibility with advanced security configuration."
            case .hipaaCompliantStorage: return "Your media is stored using HIPAA-compliant infrastructure and safeguards."
            case .prioritySupport: return "Get priority access to our support team whenever you need help."
            }
        }
        
        var icon: ImageSource {
            switch self {
            case .imagesPerMonth: return .systemImage("camera.on.rectangle")
            case .unlimitedLocations: return .systemImage("pin")
            case .unlimitedTeamInvites: return .systemImage("person.3.fill")
            case .customSecuritySettings: return .systemImage("shield.lefthalf.fill")
            case .hipaaCompliantStorage: return .systemImage("lock.shield.fill")
            case .prioritySupport: return .systemImage("bolt.circle.fill")
            }
        }
    }
    
    internal let loggerName: String = "PAYWALL_VIEW_MODEL"
    internal let loggerEmoji: String = "👮🏻‍♂️"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol

    @Published private(set) var shouldDismiss: Bool = false
        
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
    func setup() -> Self {
        
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
    }
    
    func subscribe() {
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension SubscriptionPaywallViewModel {
    
    func track() {
        self.analyticsService.track(screen: .subscription(.paywall))
    }
    
}
