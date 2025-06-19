//
//  TabBar4Screen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct TabBar4Screen: View {
    
    @StateObject var viewModel: Tab4ViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService.tab4NavigationService)
        
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
        EmptyView()
    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab4ViewModel.self)
    
    TabBar4Screen(viewModel: viewModel, tab: .tab4)
        .withMockServices()
    
}
