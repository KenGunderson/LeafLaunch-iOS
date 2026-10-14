//
//  TabBar2Screen.swift
//  LeafLaunch
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
        
        AppRootView(navigationService: nav) {
            
            AppHeaderScrollView(horizontalPadding: .medium) {
                
            } scrollViewContent: {
                
                content()
                
            }
            // Lifecycle
            
            .onFirstAppear { [weak viewModel] in
                
                viewModel?
                    .track()
                
                viewModel?.setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            .task { [weak viewModel] in
                
                viewModel?
                    .loadData(showHud: true)
                
            }
            
        }
        .tag(self.tab)
        
    }
    
    private func content() -> some View {

        VStack(spacing: Style.shared.spacing(.medium)) {

            LeafLaunchCardView(title: "Capsule Buttons") {

                Text("Screens use LeafLaunchButton instead of configuring CommonButton directly.")
                    .appFont(with: .BODY_3)
                    .foregroundStyle(.text(.body))

                LeafLaunchButton(
                    title: "Show Alert",
                    icon: .systemImage("bell")
                ) {

                    self.viewModel.presentAlert()

                }

            }

            LeafLaunchCardView(title: "App-Owned Card") {

                Text("The wrapper owns the card padding, radius, shadow, and title hierarchy.")
                    .appFont(with: .BODY_3)
                    .foregroundStyle(.text(.body))

                LeafLaunchButton(
                    title: "Toggle Light / Dark",
                    icon: .systemImage("paintpalette")
                ) {

                    self.viewModel.toggleTheme()

                }

            }

        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab2ViewModel.self)
    
    TabBar2Screen(viewModel: viewModel, tab: .tab2)
        .withMockServices()
    
}
