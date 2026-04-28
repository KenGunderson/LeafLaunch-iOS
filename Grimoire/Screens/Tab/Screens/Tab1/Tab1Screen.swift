//
//  TabBar1Screen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct TabBar1Screen: View {
    
    @StateObject var viewModel: Tab1ViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService.tab1NavigationService)
        
        AppRootView(navigationService: nav) {
            
            AppHeaderScrollView(horizontalPadding: .medium) {
                
                navBarView()
                
            } scrollViewContent: {
                
                content()
                
            }
            // Lifecycle
            
            .onFirstAppear { [weak viewModel] in
                
                viewModel?
                    .track()
                
                viewModel?
                    .setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            .task { [weak viewModel] in
                
                viewModel?
                    .loadData(showHud: true)
                
            }
            
        }
        .tag(self.tab)
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavHeader(
            title: "",
            showLogo: true,
            trailingNavButtons: [
                .bell(notificationCount: 0),
                .settings
            ]
        ) { navItem in
            
            switch navItem {
            case .bell:
                
                ToastManager.shared
                    .present(toastItem: .init(title: "Some New Toast"))
                
                self.viewModel
                    .presentAlert()
                
            case .settings:
                
                self.tabBarNavigationService
                    .tab1NavigationService
                    .modal(fullScreenCover: .settings)
                
            default: fatalError("Not Implemented")
            }
            
        }
        .padding(.top, 1)
        .padding(.bottom, .custom(4))
        .overlay(alignment: .bottom) {
            
            Rectangle()
                .fill(Style.shared.background(.quaternary).source())
                .frame(height: 1.5)
                .offset(y: Style.shared.spacing(.extraSmall))
            
        }
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        CommonButton(title: "Logout") {
            
            self.viewModel
                .logout()
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab1ViewModel.self)
    
    TabBar1Screen(viewModel: viewModel, tab: .tab1)
        .withMockServices()
    
}
