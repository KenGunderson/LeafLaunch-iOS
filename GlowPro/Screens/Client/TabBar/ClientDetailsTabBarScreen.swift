//
//  ClientDetailsTabBarScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/1/25.
//

import SwiftUI

struct ClientDetailsTabBarScreen: GPView {
 
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var clientDetailsViewModel: ClientDetailsViewModel
    @StateObject var tab2ViewModel: Tab2ViewModel
    @StateObject var tab3ViewModel: Tab3ViewModel
    @StateObject var tab4ViewModel: Tab4ViewModel
    
    @State private var tabBarNavigationService = TabBarNavigationService()
    
    var body: some View {
        
        TabBarScreen(
            selectedTab: self.$tabBarNavigationService.selectedTab,
            isTabBarVisibile: self.$tabBarNavigationService.isTabBarVisible,
            clientDetailsViewModel: self.clientDetailsViewModel,
            tab2ViewModel: self.tab2ViewModel,
            tab3ViewModel: self.tab3ViewModel,
            tab4ViewModel: self.tab4ViewModel
        )
        .environment(self.tabBarNavigationService)
        
    }
    
}
