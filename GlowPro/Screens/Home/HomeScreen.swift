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
            navigationService: Bindable(navigationService),
            alertService: nil) { // Setting Alert Service as Nill so we still use our current AlertService from Root
             
                AppHeaderScrollView(horizontalPadding: .medium) {
                    
                    navBarView()
                    
                } scrollViewContent: {
                    
                    content()
                    
                }
                // Lifecycle
                
                .onAppear {
                    
                    // Reset Active Destination
                    
                    self.viewModel
                        .setActiveDestination(nil)
                    
                }
                
                .onFirstAppear {
                    
                    self.viewModel
                        .track()
                    
                    self.viewModel
                        .setup(navigationService: self.navigationService)
                                        
                }
                .task {
                    
                    self.viewModel
                        .loadData()
                    
                }
                
                .sheet(isPresented: self.$viewModel.shouldShowChecklistCompletionSheet) {
                    ChecklistCompleteSheet()
                }
                
            }
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavHeader(
            title: "Good Morning, Sako",
            subtitle: "Select where you're working today",
            avatar: .initials(name: "Sako Hovaguimian"),
            trailingNavButtons: [
                .bell(notificationCount: self.viewModel.pendingInvites.count),
                .settings
            ]
        ) { navItem in
            
            switch navItem {
            case .bell: self.navigationService.push(.business(.businessEmployeeInviteList(context: .personal)))
            case .settings: self.navigationService.modal(fullScreenCover: .settings)
            default: fatalError("Not Implemented")
            }
            
        }
        .padding(.bottom, .custom(4))
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            SectionView(leadingTitle: "First Steps", showDivider: true)
            
            ChecklistView(checklistItems: self.viewModel.checklistItems)
            
            SectionView(leadingTitle: "Choose Your Location", showDivider: true)
            
            workspacesList()
            
            itemViews()
                .padding(.top, .small)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func itemViews() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            InfoView(
                title: "You Have Pending Invites",
                titleFont: .TITLE_4,
                imageSource: .systemImage("bell.fill"),
                foregroundStyle: .color(.indigo),
                clipShape: .init(.rect(cornerRadius: Style.shared.radius(.small2))),
                appBorderConfig: .init(
                    cornerRadius: .small2,
                    tintColor: .color(.indigo),
                    lineWidth: 2
                )
            ) {
                self.navigationService.push(.business(.businessEmployeeInviteList(context: .personal)))
            }
            
            InfoView(
                title: "My Business Dashboard",
                titleFont: .TITLE_4,
                imageSource: .systemImage("bell.fill"),
                foregroundStyle: Style.shared.accent,
                clipShape: .init(.rect(cornerRadius: Style.shared.radius(.small2))),
                appBorderConfig: .init(
                    cornerRadius: .small2,
                    tintColor: Style.shared.accent,
                    lineWidth: 2
                )
            ) {
                
                self.viewModel.setActiveDestination(.business(businessId: MockModels.ID.business1))
                self.navigationService.push(.business(.businessHome(businessId: MockModels.ID.business1)))
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func workspacesList() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            ForEach(self.viewModel.workspaces, id: \.id) { workspace in
                
                ForEach(workspace.roleLocations, id: \.id) { roleLocation in
                    
                    LocationCardView(
                        businessName: workspace.name,
                        businessLocation: roleLocation.location,
                        role: roleLocation.role
                    )
                    .asButton {
                        
                        self.viewModel.setActiveDestination(.location(locationId: roleLocation.location.id))
                        self.navigationService.push(.business(.businessLocationHome(locationId: roleLocation.location.id)))
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(HomeViewModel.self)
    
    HomeScreen(viewModel: viewModel)
        .withMockServices()
    
}


//if let currentUser = self.viewModel.currentUser {
//    
//    VStack(spacing: 8) {
//        
//        Text(currentUser.email + " (Logged in)")
//        Text(currentUser.name + " (Joined App)")
//        
//    }
//    .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))
//    
//}
//
//VStack(spacing: Style.shared.spacing(.medium)) {
//    
//    // Business
//    
//    CommonButton(title: "Business Edit Details",
//                 titleColor: Style.shared.textColor(.button)) {
//        
//        self.navigationService
//            .push(.business(.businessEditDetails(businessId: MockModels.ID.business1)))
//        
//    }
//    
//    CommonButton(title: "Business Locations",
//                 titleColor: Style.shared.textColor(.button)) {
//        
//        self.navigationService
//            .push(.business(.businessLocations(businessId: MockModels.ID.business1)))
//        
//    }
//    
//    CommonButton(title: "Business Create Locations",
//                 titleColor: Style.shared.textColor(.button)) {
//        
//        self.navigationService
//            .push(.business(.businessLocationCreate(businessId: MockModels.ID.business1)))
//        
//    }
//    
//    CommonButton(title: "Business Employees",
//                 titleColor: Style.shared.textColor(.button)) {
//        
//        self.navigationService
//            .push(.business(.businessEmployees(businessId: MockModels.ID.business1)))
//        
//    }
//    
//    CommonButton(title: "Business Invite Employees",
//                 titleColor: Style.shared.textColor(.button)) {
//        
//        self.navigationService
//            .push(.business(.businessEmployeesInvite(businessId: MockModels.ID.business1)))
//        
//    }
//    
//    CommonButton(title: "Business Invited List",
//                 titleColor: Style.shared.textColor(.button)) {
//        
//        self.navigationService
//            .push(.business(.businessEmployeeInviteList(businessId: MockModels.ID.business1)))
//        
//    }
//    
//    CommonButton(title: "Business Update Employees",
//                 titleColor: Style.shared.textColor(.button)) {
//        
//        self.navigationService
//            .push(.business(.businessEmployeesUpdate(
//                businessId: MockModels.ID.business1,
//                employeeId: MockModels.ID.employee1
//            )))
//        
//    }
//    
//    CommonButton(title: "Business Employee Join",
//                 titleColor: Style.shared.textColor(.button)) {
//        
//        self.navigationService
//            .modal(sheet: .businessEmployeeJoin)
//        
//    }
//    
//    // Client
//    
//    CommonButton(title: "Client List",
//                 titleColor: Style.shared.textColor(.button)) {
//        
//        self.navigationService
//            .push(.clientList)
//        
//    }
//    
//    // Onboarding
//    
//    CommonButton(style: .outline(lineWidth: 5),
//                 title: "Onboarding",
//                 titleColor: Style.shared.accent) {
//        
//        self.navigationService
//            .modal(fullScreenCover: .onboarding)
//        
//    }
//    
//}
//
//}
//.frame(maxWidth: .infinity)
//.animation(.smooth(duration: 0.4), value: self.viewModel.currentUser)
