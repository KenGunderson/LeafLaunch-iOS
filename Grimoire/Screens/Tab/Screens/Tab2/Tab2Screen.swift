//
//  TabBar2Screen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct TabBar2Screen: View {
    
    @StateObject var viewModel: Tab2ViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    @State private var time = WheelTime(
        hour: 1,
        minute: 00,
        period: .am
    )
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService.tab2NavigationService)
        
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
                
                self.viewModel
                    .loadData(showHud: false)
                
            }
            
        }
        .tag(self.tab)
        
    }
    
    private func content() -> some View {
        
        WheelTimePicker(
            time: self.$time
        )
        
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab2ViewModel.self)
    
    TabBar2Screen(viewModel: viewModel, tab: .tab2)
        .withMockServices()
    
}
