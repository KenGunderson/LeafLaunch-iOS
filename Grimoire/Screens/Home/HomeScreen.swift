//
//  HomeScreen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/1/25.
//

import SwiftUI

struct HomeScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationService.self) private var navigationService
        
    @StateObject private var viewModel: HomeViewModel
    
    public init(viewModel: HomeViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
                
        AppRootView(
            navigationService: Bindable(self.navigationService),
            alertService: nil) { // Setting Alert Service as Nill so we still use our current AlertService from Root
             
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
                                        
                }
                .task {
                    
                    self.viewModel
                        .loadData(showHud: false)
                    
                }
                
            }
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavHeader(
            title: "",
            showLogo: true,
            trailingNavButtons: [
                .bell(notificationCount: 0),
                .settings
            ]
        ) { navItem in
            
            switch navItem {
            case .bell: print("bell")
            case .settings: print("settings")
            default: fatalError("Not Implemented")
            }
            
        }
        .padding(.top, 1)
        .padding(.bottom, .custom(4))
        .overlay(alignment: .bottom) {
            
            Rectangle()
                .fill(Style.shared.background(.quaternary).source())
                .frame(height: 1.5)
                .offset(y: Style.shared.spacing(.extraSmall))
            
        }
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        Color.red.ignoresSafeArea()
    }
    
}

#Preview {
    
    let viewModel = mockResolve(HomeViewModel.self)
    
    HomeScreen(viewModel: viewModel)
        .withMockServices(withNaivgationService: true)
    
}
