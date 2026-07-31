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

            GrimoireCardView(title: "Capsule Buttons") {

                Text("Screens use GrimoireButton instead of configuring CommonButton directly.")
                    .appFont(with: .BODY_3)
                    .foregroundStyle(.text(.body))

                GrimoireButton(
                    title: "Show Alert",
                    icon: .systemImage("bell")
                ) {

                    self.viewModel.presentAlert()

                }

            }

            GrimoireCardView(title: "App-Owned Card") {

                Text("The wrapper owns the card padding, radius, shadow, and title hierarchy.")
                    .appFont(with: .BODY_3)
                    .foregroundStyle(.text(.body))

                GrimoireButton(
                    title: "Change Theme",
                    icon: .systemImage("paintpalette")
                ) {

                    self.viewModel.setRandomTheme()

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
