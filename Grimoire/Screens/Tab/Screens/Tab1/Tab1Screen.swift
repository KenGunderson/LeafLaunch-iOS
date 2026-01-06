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
                
        AppRootView(
            navigationService: nav,
            alertService: nil) { // Setting Alert Service as Nill so we still use our current AlertService from Root
             
                AppHeaderScrollView(horizontalPadding: .medium) {
                    
                    navBarView()
                    
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
                    
//                    self.viewModel
//                        .loadData(showHud: false)
                    
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
            case .bell: print("bell")
            case .settings: print("settings")
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
        Color.red.ignoresSafeArea()
    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab1ViewModel.self)
    
    TabBar1Screen(viewModel: viewModel, tab: .tab1)
        .withMockServices()
    
}
