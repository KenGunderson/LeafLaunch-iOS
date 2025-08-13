//
//  BusinessLocationHomeScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/13/25.
//

import SwiftUI

struct BusinessLocationHomeScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationService.self) private var navigationService
    
    @StateObject private var viewModel: BusinessLocationHomeViewModel
    
    public init(viewModel: BusinessLocationHomeViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            
            navBarView()
            
        } scrollViewContent: {
            
            content()
            
        }
        
        // Lifecycle
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
            self.viewModel
                .loadData()
            
        }
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavHeader(
            title: self.viewModel.location?.name ?? "",
            subtitle: self.viewModel.location?.formattedAddress ?? "",
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { navItem in
                
                switch navItem {
                case .back: self.dismiss()
                default: fatalError("Not Implemented")
                }
                
            },
            trailingNavButtons: [.settings]) { navItem in
                
                switch navItem {
                case .settings: self.navigationService.modal(fullScreenCover: .settings)
                default: fatalError("Not Implemented")
                }
                
            }
            .padding(.bottom, .custom(4))
            .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        EmptyView()
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessLocationHomeViewModel.self)
        .setup(locationId: MockModels.ID.location1)
    
    BusinessLocationHomeScreen(viewModel: viewModel)
        .withMockServices()
    
}
