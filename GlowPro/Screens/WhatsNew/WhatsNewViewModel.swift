//
//  WhatsNewViewModel.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 3/7/25.
//

import SwiftUI
import Combine

final class WhatsNewViewModel: ViewModel {
    
    internal let loggerName: String = "WHATS_NEW_VIEW_MODEL"
    internal let loggerEmoji: String = "🔁"
    
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var cancelBag: CancelBag!
        
    @Published private(set) var whatsNewItem: WhatsNewItem?
        
    init(analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
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
