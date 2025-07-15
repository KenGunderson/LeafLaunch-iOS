//
//  BusinessLocationsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import SwiftUI

struct BusinessLocationsScreen: GPView {
    
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessLocationsViewModel
    
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
            title: "Locations",
            leftButtonView: backButton
        )
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            ForEach(self.viewModel.locations, id: \.id) { location in
                
                AppCardView {
                    
                    Text(location.name)
                        .appFont(with: .TITLE_T6)
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
    
    let viewModel = mockResolve(BusinessLocationsViewModel.self)
        .setup(businessId: "123")
    
    BusinessLocationsScreen(viewModel: viewModel)
        .withMockServices()
    
}
