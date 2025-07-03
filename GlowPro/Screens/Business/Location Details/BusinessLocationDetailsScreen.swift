//
//  BusinessLocationDetailsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import SwiftUI

struct BusinessLocationDetailsScreen: GPView {
    
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessLocationDetailsViewModel
    
    var body: some View {
        
        content()
        
        // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            .onAppear {
                
                self.tabBarNavigationService
                    .shouldShowTabBar(false)
                
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
        
        let backButton = BackButton(backgroundColor: .color(.clear)) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Location Details",
            leftButtonView: backButton
        )
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            AppCardView {
                
                VStack(alignment: .leading) {
                    
                    Text(self.viewModel.location?.name ?? "")
                        .appFont(with: .TITLE_T6)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                    Text(self.viewModel.location?.address.street ?? "")
                        .appFont(with: .TITLE_T4)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                }
                
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        
        Text(title)
            .foregroundStyle(Style.shared.textColor(.title).source())
            .appFont(with: .TITLE_T8)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessLocationDetailsViewModel.self)
        .setup(
            businessId: "123",
            locationId: "123"
        )
    
    BusinessLocationDetailsScreen(viewModel: viewModel)
        .withMockServices()
    
}
