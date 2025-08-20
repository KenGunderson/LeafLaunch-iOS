//
//  MediaGalleryScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import SwiftUI

struct MediaGalleryScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: MediaGalleryViewModel
        
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            content()
        }
        
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
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Photo Gallery",
            leftButtonView: backButton
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        Text("Gallery")
    }
    
}

#Preview {
    
    let viewModel = mockResolve(MediaGalleryViewModel.self)
    
    MediaGalleryScreen(viewModel: viewModel)
        .withMockServices()
    
}
