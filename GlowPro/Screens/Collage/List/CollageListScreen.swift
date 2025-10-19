//
//  CollageListScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/18/25.
//

import SwiftUI

struct CollageListScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: CollageListViewModel
    
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
            collageList()
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
                .push(.collage(.createEdit(
                    clientId: self.viewModel.clientId,
                    collageId: nil
                )))
            
        }
        .asAnyView()
        
        return NavBarView(
            title: "Collages",
            leftButtonView: backButton,
            rightButtonView: self.viewModel.allowsCollageCreation ? plusButton : nil
        )
        
    }
    
    
    private func collageList() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            ForEach(self.viewModel.collages, id: \.id) { collage in
                collageItem(collage)
            }
            
        }
        .padding(.horizontal, .medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func collageItem(_ collage: Collage) -> some View {
        
        CollageView(
            items: collage.mediaURLs,
            type: collage.type,
            height: 350
        )
        
    }

}

#Preview {
    
    let viewModel = mockResolve(CollageListViewModel.self)
        .setup(context: .client(clientId: MockModels.ID.client1))
    
    CollageListScreen(viewModel: viewModel)
        .withMockServices()
    
}
