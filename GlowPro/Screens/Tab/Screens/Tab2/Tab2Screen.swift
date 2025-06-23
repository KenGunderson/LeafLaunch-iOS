//
//  TabBar2Screen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct TabBar2Screen: View {
    
    @StateObject var viewModel: Tab2ViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService.tab2NavigationService)
        
        NavigationStack(path: (nav.routes)) {
            
            content()
            
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
    
    let viewModel = mockResolve(Tab2ViewModel.self)
    
    TabBar2Screen(viewModel: viewModel, tab: .tab2)
        .withMockServices()
    
}
