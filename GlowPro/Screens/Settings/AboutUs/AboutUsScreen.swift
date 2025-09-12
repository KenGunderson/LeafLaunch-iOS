//
//  AboutUsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/12/25.
//

import SwiftUI
import Charts

struct AboutUsScreen: GPView {
    
    @StateObject var viewModel: AboutUsViewModel
    @Environment(NavigationService.self) private var navigationService
    
    @State private var onAppearAnimation: Bool = false
            
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            headerView()
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.onAppearAnimation = true
            }
            
        }

    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "About Us",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        let config = Constants.StaggerAnimation.config(interitemSpacing: 16)
        
        StaggeredView(config: config) {
            
            if self.onAppearAnimation {
                
                Text(self.viewModel.aboutUsMessage())
                    .appFont(with: .BODY_4)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
            }
            
        }
        
    }
    
}

#Preview {
    
    AboutUsScreen(
        viewModel: mockResolve(AboutUsViewModel.self)
    )
    .withMockServices()
    
}
