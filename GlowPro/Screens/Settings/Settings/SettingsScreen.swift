//
//  SettingsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/21/25.
//

import SwiftUI

struct SettingsScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: SettingsViewModel
    @State private var navigationService = NavigationService()
    
    @State private var onAppearAnimation: Bool = false
        
    var body: some View {
        
        AppRootView(
            navigationService: self.$navigationService,
            alertService: self.viewModel.alertService
        ) {
                
            AppHeaderScrollView {
                navBar()
            } scrollViewContent: {
                content()
            }
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.onAppearAnimation = true
                }
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
            
        }
        
    }
    
    private func navBar() -> some View {
        
        let closeButton = CircularIconView(
            foregroundColor: .color(.black),
            backgroundColor: .color(.clear),
            imageSource: .systemImage("xmark"),
            size: 32
        )
        .asButton {
            dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Settings",
            rightButtonView: closeButton
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        let config = StaggeredConfig.init(
            delay: 0.05,
            maxDelay: 0.05,
            blurRadius: 0.5,
            offset: .init(width: 0, height: 100),
            scale: 1,
            scaleAnchor: .center,
            animation: .smooth,
            disappearInSameDirection: true,
            noDisappearAnimation: false
        )
        
        StaggeredView(config: config) {
            
            if self.onAppearAnimation {
                
                ForEach(Route.Setting.allCases, id: \.self) { item in
                    settingItem(item)
                }
                
            }
            
        }
        
    }
    
    private func settingItem(_ item: Route.Setting) -> some View {
        
        AppCardView(shadow: .subtle) {
            
            HStack(spacing: Style.shared.spacing(.small)) {
                
                Image(systemName: item.icon)
                    .appFont(with: .TITLE_T5)
                    .foregroundStyle(item.tintColor.source())
                
                Text(item.displayName)
                    .appFont(with: .TITLE_T5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .opacity(0.5)
                
            }
            .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        .asButton {
            
            withAnimation(.smooth) {
                
                self.viewModel
                    .selectSetting(item)
                
            }
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(SettingsViewModel.self)
    
    SettingsScreen(viewModel: viewModel)
        .withMockServices()
    
}
