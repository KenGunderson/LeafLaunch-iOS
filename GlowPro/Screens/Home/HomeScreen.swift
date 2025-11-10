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
                        .loadData(showHud: false)
                    
                }
                
            }
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        let currentUser = viewModel.currentUser
        let subtitle = self.viewModel.hasActiveWorkspace
            ? "Select where you're working today"
            : "Let's get started"
        
        NavHeader(
            title: "Good Morning, \(currentUser?.firstName ?? "")",
            subtitle: subtitle,
            avatar: .initials(name: currentUser?.fullName ?? ""),
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
        .padding(.top, 1)
        .padding(.bottom, .custom(4))
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
                        
            let hasActiveBusiness = self.viewModel.hasActiveBusiness
            
            BusinessDashboardView(isBusinessActive: hasActiveBusiness)
                .asButton {
                   
                    if hasActiveBusiness {
                        
                        if let business = self.viewModel.workspaces.first(where: { $0.isOwner }) {
                            
                            self.navigationService.push(.business(.businessHome(businessId: business.id)))
                            
                        }
                        
                    } else {
                        
                        self.navigationService
                            .push(.business(.businessCreateEdit(businessId: nil)))
                        
                    }
                    
                }
            
            if self.viewModel.hasActiveWorkspace && self.viewModel.hasRoleLocations {
                
                SectionView(
                    leadingTitle: "Choose Your Location",
                    showDivider: true
                )
                
                workspacesList()
                
            } else {
                emptyStateView()
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func emptyStateView() -> some View {
        
        VStack {
            
            HStack {
                
                Rectangle()
                    .fill(Style.shared.background(.quaternary).source())
                    .frame(maxWidth: .infinity)
                    .frame(height: 1.5)
                
                Text("or")
                    .appFont(with: .BODY_2)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
                Rectangle()
                    .fill(Style.shared.background(.quaternary).source())
                    .frame(maxWidth: .infinity)
                    .frame(height: 1.5)
                
            }
            
            BusinessEmployeeInviteView(email: self.viewModel.currentUser?.email ?? "")
                .asButton {
                 
                    self.navigationService
                        .push(.business(.businessEmployeeInviteList(context: .personal)))
                    
                }
            
        }
        
    }
    
    @ViewBuilder
    private func workspacesList() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            ForEach(self.viewModel.workspaces, id: \.id) { workspace in
                
                ForEach(workspace.roleLocations, id: \.self) { roleLocation in
                    
                    LocationCardView(
                        businessName: workspace.name,
                        businessLocation: roleLocation.location,
                        role: roleLocation.role
                    )
                    .asButton {
                        
                        self.navigationService.push(.business(.businessLocationHome(locationId: roleLocation.location.id)))
                        
                    }
                    
                }
                
            }
            
            ForEach(self.viewModel.simpleWorkspaces, id: \.id) { workspace in
                
                PendingLocationView(simpleWorkspace: workspace)
                
            }
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(HomeViewModel.self)
    
    HomeScreen(viewModel: viewModel)
        .withMockServices(withNaivgationService: true)
    
}
