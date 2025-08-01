//
//  TabBar1Screen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct TabBar1Screen: GPView {
    
    @StateObject var viewModel: Tab1ViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService.tab1NavigationService)
        
        NavigationStack(path: nav.routes) {
            
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
            
                .onAppear {
                    
                    self.tabBarNavigationService
                        .shouldShowTabBar(true)
                    
                }
            
        }
        .tag(self.tab)
        
    }
    
    private func content() -> some View {
        
        AppBaseView {
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
               Text("Tab 1 Screen")
                
            }
            .padding(.horizontal, .large)
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab1ViewModel.self)
    
    TabBar1Screen(viewModel: viewModel, tab: .tab1)
        .withMockServices()
    
}
