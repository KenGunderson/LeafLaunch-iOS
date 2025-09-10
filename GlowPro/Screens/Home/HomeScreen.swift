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
                        
            let hasActiveBusiness = self.viewModel.workspaces.contains(where: { $0.isOwner })
            
            BusinessDashboardView(isBusinessActive: hasActiveBusiness)
                .asButton {
                   
                    if hasActiveBusiness {
                        
                        if let business = self.viewModel.workspaces.first(where: { $0.isOwner }) {
                            
                            self.viewModel.setActiveDestination(.business(businessId: business.id))
                            self.navigationService.push(.business(.businessHome(businessId: business.id)))
                            
                        }
                        
                    } else {
                        
                        self.navigationService
                            .push(.business(.businessCreateEdit(businessId: nil)))
                        
                    }
                    
                }
            
            SectionView(leadingTitle: "Choose Your Location", showDivider: true)
            
            workspacesList()
            
            itemViews()
                .padding(.top, .small)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func itemViews() -> some View {
        
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
