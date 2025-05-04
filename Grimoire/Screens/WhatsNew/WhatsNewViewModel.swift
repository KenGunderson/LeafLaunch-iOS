//
//  WhatsNewViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 3/7/25.
//

import SwiftUI
import Combine

final class WhatsNewViewModel: ViewModel {
    
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private let logger = GrimoireLogger.viewModel(.whatsNew)
    private var cancelBag: CancelBag!
        
    @Published private(set) var whatsNewItem: WhatsNewItem?
        
    init(analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        self.logger.logInit()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    @discardableResult
    func setup(whatsNewItem: WhatsNewItem) -> Self {
        
        self.whatsNewItem = whatsNewItem
        
        self.userDefaultsService
            .set(lastViewedWhatsNewVersion: whatsNewItem.version.description)
        
        return self
        
    }
    
}

extension WhatsNewViewModel {
    
    func track() {
        self.analyticsService.track(screen: .whatsNew)
    }
    
}
