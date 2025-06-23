//
//  TabBar3Screen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct TabBar3Screen: View {
    
    @StateObject var viewModel: Tab3ViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService.tab3NavigationService)
        
        NavigationStack(path: (nav.routes)) {
            
            content()
                .tag(self.tab)
            
            // Navigation
            
            .withNavigationDestination()
            .withSheetDestination(nav.sheet)
            .withFullScreenCover(nav.fullScreenCover)
            
            // Lifecycle
            
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            
        }
        .tag(self.tab)
        
    }
    
    private func content() -> some View {
        AppBaseView {}
    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab3ViewModel.self)
    
    TabBar3Screen(viewModel: viewModel, tab: .tab3)
        .withMockServices()
    
}
