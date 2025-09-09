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
                locationItem(location)
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func locationItem(_ location: Location) -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
                
                Text(location.name)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Text(location.address.fullFormattedAddress)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0),
                    GridItem(.flexible(), spacing: 0)
                ], spacing: 0) {
                    
                    statView(
                        title: "Employees",
                        value: "\(location.employees.count)",
                        icon: .systemImage("person.2.fill")
                    )
                    
                    statView(
                        title: "Clients",
                        value: "\(location.clients.count)",
                        icon: .systemImage("person.3.fill")
                    )
                    
                    statView(
                        title: "Media",
                        value: "\(location.media.count)",
                        icon: .systemImage("photo.on.rectangle.fill")
                    )
                    
                }
                
                HStack(spacing: 4) {
                    
                    CommonButton(title: "View Dashboard",
                                 verticalPadding: .small) {
                        
                        self.viewModel
                            .setActiveDestination(.location(locationId: location.id))
                        
                        self.navigationService
                            .push(.business(.businessLocationHome(locationId: location.id) {
                                
                                self.viewModel
                                    .setActiveDestination(.business(businessId: self.viewModel.businessId))
                                
                            }))
                        
                    }
                    .frame(maxWidth: .infinity)
                    
                    Image(systemName: "pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 18)
                        .padding(9)
                        .foregroundStyle(.white)
                        .background(Style.shared.accent.source())
                        .cornerRadius(.small)
                        .asButton {
                            
                            self.navigationService
                                .push(.business(
                                    .businessLocationCreateEdit(
                                        businessId: self.viewModel.businessId,
                                        locationId: location.id
                                    )
                                ))
                            
                        }
                    
                }
                
            }
            
        }
        
        .onChange(of: self.navigationService.routes) { oldValue, newValue in
            
            if oldValue.last == .business(.businessLocationHome(
                locationId: location.id,
                completion: nil)) {
                
                self.viewModel
                    .setActiveDestination(.business(businessId: self.viewModel.businessId))
                
            }
            
        }
        
    }
    
    @ViewBuilder
    func statView(title: String,
                  value: String,
                  icon: ImageSource) -> some View {
        
        VStack(spacing: Style.shared.spacing(.none)) {
            
            Text(value)
                .appFont(with: .HEADER_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            Text(title)
                .appFont(with: .TITLE_2)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        
    }

}

#Preview {
    
    let viewModel = mockResolve(BusinessLocationListViewModel.self)
        .setup(businessId: MockModels.ID.business1)
    
    BusinessLocationListScreen(viewModel: viewModel)
        .withMockServices()
    
}
