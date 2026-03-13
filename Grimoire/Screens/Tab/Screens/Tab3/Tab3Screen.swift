//
//  TabBar3Screen.swift
//  Grimoire
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
        
        AppRootView(navigationService: nav) {
            
            AppHeaderScrollView(horizontalPadding: .medium) {
                
            } scrollViewContent: {
                
                content()
                
            }
            // Lifecycle
            
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            .task {
//                
//                self.viewModel
//                    .loadData(showHud: false)
                
            }
            
        }
        .tag(self.tab)
        
    }
    
    private func content() -> some View {
        EmptyView()
    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab3ViewModel.self)
    
    TabBar3Screen(viewModel: viewModel, tab: .tab3)
        .withMockServices()
    
}
