//
//  TabBarNavigationService.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 1/5/26.
//

import SwiftUI
import Observation

@Observable
public final class TabBarNavigationService: Sendable {

    var selectedTab: Tab = .tab1
    var isTabBarVisible: Bool = true
    private(set) var storeLocationId: String?

    let tab1NavigationService = NavigationService()
    let tab2NavigationService = NavigationService()
    let tab3NavigationService = NavigationService()
    let tab4NavigationService = NavigationService()

    func initializeStoreExperience(locationId: String) {

        guard self.storeLocationId != locationId else { return }

        resetPathItems()

        self.storeLocationId = locationId
        self.selectedTab = .tab1
        self.isTabBarVisible = true

    }

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
