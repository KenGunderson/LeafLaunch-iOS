//
//  TabBarNavigationService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import SwiftUI

@Observable
public class TabBarNavigationService {
    
    var selectedTab: Tab = .tab1
    var isTabBarVisible: Bool = true
    
    var tab1NavigationService = NavigationService()
    var tab2NavigationService = NavigationService()
    var tab3NavigationService = NavigationService()
    var tab4NavigationService = NavigationService()
    
    func select(_ tab: Tab) {
        
        withAnimation {
            self.selectedTab = tab
        }
        
    }
    
    func resetPathItems() {
        
        self.tab1NavigationService.routes = []
        self.tab2NavigationService.routes = []
        self.tab3NavigationService.routes = []
        self.tab4NavigationService.routes = []
        
    }
    
    func shouldShowTabBar(_ shouldShow: Bool) {
        
        withAnimation {
            self.isTabBarVisible = shouldShow
        }
        
    }
    
    func currentNavigationService() -> NavigationService {
        
        switch self.selectedTab {
        case .tab1: return self.tab1NavigationService
        case .tab2: return self.tab2NavigationService
        case .tab3: return self.tab3NavigationService
        case .tab4: return self.tab4NavigationService
        }
        
    }
    
}
