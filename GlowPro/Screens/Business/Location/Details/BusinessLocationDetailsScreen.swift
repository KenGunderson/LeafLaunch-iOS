//
//  BusinessLocationDetailsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import SwiftUI

struct BusinessLocationDetailsScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessLocationDetailsViewModel
    
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
        
        let trailingButtons = HStack {
            
            if self.viewModel.isOwner {
                
                NavBarButton(style: .trash) {
                    
                    self.viewModel
                        .presentDeleteLocationAlert()
                    
                }
                
            }
            
            NavBarButton(style: .pencil) {
                
                self.navigationService
                    .push(.business(.businessLocationCreateEdit(
                        businessId: self.viewModel.businessId,
                        locationId: self.viewModel.location?.id
                    )))
                
            }
            
        }
        .asAnyView()
        
        return NavBarView(
            title: "Location Details",
            leftButtonView: backButton,
            rightButtonView: trailingButtons
        )
        
    }
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            AppCardView {
                
                VStack(alignment: .leading) {
                    
                    Text(self.viewModel.location?.name ?? "")
                        .appFont(with: .TITLE_5)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                    Text(self.viewModel.location?.address.street ?? "")
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                }
                
            }
            .asButton {
                
                self.viewModel
                    .setActiveDestination(.location(locationId: self.viewModel.location?.id ?? ""))
                
                self.navigationService
                    .push(.business(.businessLocationHome(locationId: self.viewModel.location?.id ?? "") {
                       
                        self.viewModel
                            .setActiveDestination(.business(businessId: self.viewModel.businessId))
                        
                    }))
                
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessLocationDetailsViewModel.self)
        .setup(
            businessId: MockModels.ID.business1,
            locationId: MockModels.ID.location1
        )
    
    BusinessLocationDetailsScreen(viewModel: viewModel)
        .withMockServices()
    
}
