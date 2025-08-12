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
            
            ForEach(self.viewModel.employeeInvites, id: \.id) { pendingInvite in
                
                PendingInviteView(
                    employeeInvitation: pendingInvite,
                    declineAction: { self.viewModel.acceptInvite(pendingInvite) },
                    acceptAction: { self.viewModel.denyInvite(pendingInvite) }
                )
                
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessEmployeeInviteListViewModel.self)
        .setup(businessId: MockModels.ID.business1)
    
    BusinessEmployeeInviteListScreen(viewModel: viewModel)
        .withMockServices()
    
}
