//
//  DevRoutesViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import SwiftUI
import Combine

final class DevRoutesViewModel: ViewModel {
    
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func present(sheet: Sheet) {
        
        self.navigationService?
            .modal(sheet: sheet)
        
    }
    
    func present(modal: FullScreenCover) {
        
        self.navigationService?
            .modal(fullScreenCover: modal)
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension DevRoutesViewModel {
    
    func track() {
        self.analyticsService.track(screen: .devSettings(.routes))
    }
    
}
