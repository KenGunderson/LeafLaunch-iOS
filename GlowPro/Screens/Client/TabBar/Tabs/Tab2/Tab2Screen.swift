//
//  TabBar2Screen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct TabBar2Screen: GPView {
    
    @StateObject var viewModel: Tab2ViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService)
        
        AppRootView(
            navigationService: nav.tab2NavigationService,
            alertService: self.viewModel.alertService) {
                
                content()
                
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
        
        AppBaseView {
            
            Text("Tab 2")
                .asButton {
                    dismiss()
                }
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab2ViewModel.self)
    
    TabBar2Screen(viewModel: viewModel, tab: .tab2)
        .withMockServices()
    
}
