//
//  DevSettingsDeeplinkView.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI
import Charts

struct DevDeeplinksScreen: View {
    
    @StateObject var viewModel: DevDeeplinksViewModel
    @Environment(NavigationService.self) private var navigationService
    
    var basePath = "glowpro://host/"
        
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
            title: "Deeplink",
            leftButtonView: (
                BackButton {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            // Tab
            
            section(title: "Tabs")
            
            route(
                title: "Tab 1",
                deeplink: "tab?tab=tab1"
            )
            
            route(
                title: "Tab 2",
                deeplink: "tab?tab=tab2"
            )
            
            route(
                title: "Tab 3",
                deeplink: "tab?tab=tab3"
            )
            
            route(
                title: "Tab 4",
                deeplink: "tab?tab=tab4"
            )
            
        }
        
    }
    
    private func section(title: String) -> some View {
        
        Group {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
                
                Text(title)
                    .appFont(with: .HEADER_H5)
                
                Divider()
                
            }
            
        }
        .foregroundStyle(Style.shared.textColor(.title).source())
        
    }
    
    private func route(title: String,
                       deeplink: String) -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading,
                   spacing: Style.shared.spacing(.small2)
            ) {
             
                Text(title)
                    .appFont(with: .TITLE_T6)
                
                Text(deeplink)
                    .appFont(with: .TITLE_T4)
                    .fontDesign(.monospaced)
                
            }
            
        }
        .foregroundStyle(Style.shared.textColor(.title).source())
        .appOnTapGesture {
            
            if let deeplinkURL = URL(string: "\(self.basePath)\(deeplink)") {
                self.viewModel.handleDeeplink(url: deeplinkURL)
            }
            
        }
        
    }
    
}

#Preview {
    
    DevDeeplinksScreen(
        viewModel: mockResolve(DevDeeplinksViewModel.self)
    )
    .withMockServices()
    
}
