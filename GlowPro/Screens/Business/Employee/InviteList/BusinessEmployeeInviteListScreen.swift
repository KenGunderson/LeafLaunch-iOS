//
//  BusinessEmployeeInviteListScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import SwiftUI

struct BusinessEmployeeInviteListScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessEmployeeInviteListViewModel
    
    var body: some View {
        
        content()
        
        // Lifecycle
        
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
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            contentCards()
        }
        .emptyStateOverlay(
            shouldShow: self.viewModel.shouldShowEmptyState,
            config: self.viewModel.emptyStateConfig()
        )
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Pending Invites",
            leftButtonView: backButton
        )
        
    }
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            ForEach(self.viewModel.employeeInvites, id: \.id) { invite in
                inviteView(invite)
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func inviteView(_ invite: EmployeeInvite) -> some View {
        
        switch self.viewModel.context {
        case .personal:
            
            PendingInviteView(
                employeeInvitation: invite,
                declineAction: { self.viewModel.denyInvite(invite) },
                acceptAction: { self.viewModel.acceptInvite(invite) }
            )
            
        case .business:
            
            EmployeeInviteView(employeeInvitation: invite)
            
        default: EmptyView()
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessEmployeeInviteListViewModel.self)
        .setup(context: .business(businessId: MockModels.ID.business1))
    
    BusinessEmployeeInviteListScreen(viewModel: viewModel)
        .withMockServices()
    
}
