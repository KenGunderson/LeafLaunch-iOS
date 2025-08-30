//
//  BusinessLocationListScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import SwiftUI

struct BusinessLocationListScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessLocationListViewModel
    
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
        
        let plusButton = NavBarButton(style: .plus) {
            
            self.navigationService
                .push(.business(.businessLocationCreateEdit(
                    businessId: self.viewModel.businessId,
                    locationId: nil
                )))
            
        }
        .asAnyView()
        
        return NavBarView(
            title: "Locations",
            leftButtonView: backButton,
            rightButtonView: self.viewModel.isOwner ? plusButton : nil
        )
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            ForEach(self.viewModel.locations, id: \.id) { location in
                
                AppCardView {
                    
                    Text(location.name)
                        .appFont(with: .TITLE_5)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                }
                .asButton {
                    
                    self.viewModel
                        .selectLocation(location)
                    
                }
                
            }
            
        }
        .padding(.horizontal, .medium)
        
    }

}

#Preview {
    
    let viewModel = mockResolve(BusinessLocationListViewModel.self)
        .setup(businessId: MockModels.ID.business1)
    
    BusinessLocationListScreen(viewModel: viewModel)
        .withMockServices()
    
}
