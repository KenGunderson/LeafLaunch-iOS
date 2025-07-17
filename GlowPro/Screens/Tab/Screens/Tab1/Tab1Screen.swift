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
                
                // Business
                
                CommonButton(title: "Business Active Destination Selection",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.tabBarNavigationService
                        .currentNavigationService()
                        .modal(sheet: .businessActiveDestinationSelectionScreen)
                    
                }
                
                CommonButton(title: "Business Edit Details",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.tabBarNavigationService
                        .currentNavigationService()
                        .push(.business(.businessEditDetails(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Locations",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.tabBarNavigationService
                        .currentNavigationService()
                        .push(.business(.businessLocations(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Create Locations",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.tabBarNavigationService
                        .currentNavigationService()
                        .push(.business(.businessLocationCreate(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Employees",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.tabBarNavigationService
                        .currentNavigationService()
                        .push(.business(.businessEmployees(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Invite Employees",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.tabBarNavigationService
                        .currentNavigationService()
                        .push(.business(.businessEmployeesInvite(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Update Employees",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.tabBarNavigationService
                        .currentNavigationService()
                        .push(.business(.businessEmployeesUpdate(
                            businessId: MockModels.ID.business1,
                            employeeId: MockModels.ID.employee1
                        )))
                    
                }
                
                // Client
                
                CommonButton(title: "Client List",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.tabBarNavigationService
                        .currentNavigationService()
                        .push(.clientList)
                    
                }
                
                // Settings
                
                CommonButton(style: .outline(lineWidth: 5),
                             title: "Settings",
                             titleColor: Style.shared.accent) {
                    
                    self.tabBarNavigationService
                        .currentNavigationService()
                        .modal(fullScreenCover: .settings)
                    
                }
                
                // Onboarding
                
                CommonButton(style: .outline(lineWidth: 5),
                             title: "Onboarding",
                             titleColor: Style.shared.accent) {
                    
                    self.tabBarNavigationService
                        .currentNavigationService()
                        .modal(fullScreenCover: .onboarding)
                    
                }
                
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
