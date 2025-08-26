//
//  BusinessActivityListScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/24/25.
//

import SwiftUI

struct BusinessActivityListScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessActivityListViewModel
    
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
            title: "Activities",
            leftButtonView: backButton
        )
        
    }
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            ActivitiesView(activities: self.viewModel.activities)
            
        }
        .padding(.horizontal, .medium)
        
    }

}

#Preview {
    
    let viewModel = mockResolve(BusinessActivityListViewModel.self)
        .setup(context: .business(businessId: MockModels.ID.business1))
    
    BusinessActivityListScreen(viewModel: viewModel)
        .withMockServices()
    
}
