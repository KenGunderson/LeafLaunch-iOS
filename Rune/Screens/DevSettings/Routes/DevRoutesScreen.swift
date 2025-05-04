//
//  DevRoutesScreen.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI

struct DevRoutesScreen: View {
    
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
                BackButton {
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
            
            // Full Screen Covers
            
            section(title: "Full Screen")
            
            route(
                title: "Dev Settings",
                fullScreenCover: .devSettings
            )
            
        }
        
    }
    
    private func section(title: String) -> some View {
        
        Group {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                
                Text(title)
                    .appFont(with: .HEADER_H5)
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
                .appFont(with: .TITLE_T6)
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
                .appFont(with: .TITLE_T6)
            
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
