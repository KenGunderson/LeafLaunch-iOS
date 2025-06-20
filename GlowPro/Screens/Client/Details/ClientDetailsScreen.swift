//
//  ClientDetailsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import SwiftUI

struct ClientDetailsScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: ClientDetailsViewModel
    @State private var navigationService = NavigationService()
        
    var body: some View {
        
        NavigationStack(path: self.$navigationService.routes) {
            
            AppHeaderScrollView {
                // N/A
            } scrollViewContent: {
                
                content()
                
            }
            .withNavigationDestination()
            .withSheetDestination(self.$navigationService.sheet)
            .withFullScreenCover(self.$navigationService.fullScreenCover)
            
            // Lifecycle
            
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel.setup(
                    navigationService: self.navigationService,
                    dismissAction: {
                        dismiss()
                    }
                )
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
            
        }
        .withAlertService(ObservableAlertServiceWrapper(alertService: self.viewModel.alertService))
        .withToastOverlay()
        
        // Env
        
        .environment(self.navigationService)
        .environmentObject(ObservableAlertServiceWrapper(alertService: self.viewModel.alertService))
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: 24) {
            
            if let client = viewModel.client {
                
                AppCardView {
                    
                    Text(client.fullName)
                        .appFont(with: .HEADER_H10)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .asButton {
                            
                            dismiss()
                            
                        }
                    
                }
                .transition(.move(edge: .bottom))
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .animation(.smooth(duration: 0.4), value: self.viewModel.client)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab1ViewModel.self)
    
    TabBar1Screen(viewModel: viewModel, tab: .tab1)
        .withMockServices()
    
}
