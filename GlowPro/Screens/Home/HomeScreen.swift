//
//  HomeScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/1/25.
//

import SwiftUI

struct HomeScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationService.self) private var navigationService
    
    @StateObject private var viewModel: HomeViewModel
    
    public init(viewModel: HomeViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
                
        AppRootView(
            navigationService: Binding<NavigationService>(
                get: { navigationService },
                set: { _ in /* no-op because the environment value isn’t replaceable */ }
            ),
            alertService: nil) { // Setting Alert Service as Nill so we still use our current AlertService from Root
             
                AppHeaderScrollView {
                    
                    navBarView()
                    
                } scrollViewContent: {
                    
                    content()
                    
                }
                // Lifecycle
                
                .onFirstAppear {
                    
                    self.viewModel
                        .track()
                    
                    self.viewModel
                        .setup(navigationService: self.navigationService)
                    
                }
                
            }
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        let settingsButton = CircularIconView(
            foregroundColor: .color(.black),
            backgroundColor: .color(.clear),
            imageSource: .systemImage("gear"),
            size: 36
        )
        .asButton {
            
            self.navigationService
                .modal(fullScreenCover: .settings)
            
        }
        .asAnyView()
        
        NavBarView(
            title: "GlowPro",
            rightButtonView: settingsButton
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: 24) {
            
            if let currentUser = self.viewModel.currentUser {
                
                VStack(spacing: 8) {
                    
                    Text(currentUser.email + " (Logged in)")
                    Text(currentUser.name + " (Joined App)")
                    
                }
                .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))
                
            }
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                // Business
                
                CommonButton(title: "Business Edit Details",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.navigationService
                        .push(.business(.businessEditDetails(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Locations",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.navigationService
                        .push(.business(.businessLocations(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Create Locations",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.navigationService
                        .push(.business(.businessLocationCreate(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Employees",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.navigationService
                        .push(.business(.businessEmployees(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Invite Employees",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.navigationService
                        .push(.business(.businessEmployeesInvite(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Invited List",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.navigationService
                        .push(.business(.businessEmployeeInviteList(businessId: MockModels.ID.business1)))
                    
                }
                
                CommonButton(title: "Business Update Employees",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.navigationService
                        .push(.business(.businessEmployeesUpdate(
                            businessId: MockModels.ID.business1,
                            employeeId: MockModels.ID.employee1
                        )))
                    
                }
                
                CommonButton(title: "Business Employee Join",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.navigationService
                        .modal(sheet: .businessEmployeeJoin)
                    
                }
                
                // Client
                
                CommonButton(title: "Client List",
                             titleColor: Style.shared.textColor(.button)) {
                    
                    self.navigationService
                        .push(.clientList)
                    
                }
                
                // Onboarding
                
                CommonButton(style: .outline(lineWidth: 5),
                             title: "Onboarding",
                             titleColor: Style.shared.accent) {
                    
                    self.navigationService
                        .modal(fullScreenCover: .onboarding)
                    
                }
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .animation(.smooth(duration: 0.4), value: self.viewModel.currentUser)
        
    }
    
}
