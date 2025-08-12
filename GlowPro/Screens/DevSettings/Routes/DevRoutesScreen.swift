//
//  DevRoutesScreen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI

struct DevRoutesScreen: GPView {
    
    @StateObject var viewModel: DevRoutesViewModel
    @Environment(NavigationService.self) private var navigationService
    
    var body: some View {
        
        AppHeaderScrollView {
            
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
        
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "Routes",
            subtitle: "Warp To Anywhere In The App!",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            // Sheets
            
            section(title: "Sheets")
            
            route(
                title: "What's New",
                sheet: .whatsNew(Constants.WhatsNewItems.items.first!)
            )
            
            route(
                title: "Permissions",
                sheet: .permissions
            )
            
            // Full Screen Covers
            
            section(title: "Full Screen")
            
            route(
                title: "Dev Settings",
                fullScreenCover: .devSettings
            )
            
            route(
                title: "Settings",
                fullScreenCover: .settings
            )
            
            route(
                title: "Onboarding",
                fullScreenCover: .onboarding
            )
            
            route(
                title: "Client Details",
                fullScreenCover: .clientDetails(clientId: Client.DUMMY_DATA().id)
            )
            
        }
        
    }
    
    private func section(title: String) -> some View {
        
        Group {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                
                Text(title)
                    .appFont(with: .HEADER_4)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Divider()
                    .background(Style.shared.background(.quaternary).source())
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func route(title: String,
                       fullScreenCover: FullScreenCover) -> some View {
        
        AppCardView {
            
            Text(title)
                .appFont(with: .TITLE_5)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
        }
        .appOnTapGesture {
            
            self.viewModel
                .present(modal: fullScreenCover)
            
        }
        
    }
    
    @ViewBuilder
    private func route(title: String,
                       sheet: Sheet) -> some View {
        
        AppCardView {
            
            Text(title)
                .appFont(with: .TITLE_5)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
        }
        .appOnTapGesture {
            self.viewModel.present(sheet: sheet)
        }
        
    }
    
}

#Preview {
    
    DevRoutesScreen(
        viewModel: mockResolve(DevRoutesViewModel.self)
    )
    .withMockServices()
    
}
