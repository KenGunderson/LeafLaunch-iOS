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
                
            AppHeaderScrollView(horizontalPadding: .medium) {
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.onAppearAnimation = true
                }
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
            .onChange(of: self.viewModel.shouldDismiss) { _, newValue in
                
                guard newValue else { return }
                dismiss()
                
            }
            
        }
        
    }
    
    private func navBar() -> some View {
        
        let closeButton = NavBarButton(style: .close) {
            dismiss()
        }
        .padding(.trailing, .small)
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
                
                versionItem()
                
            }
            
        }
        
    }
    
    private func settingItem(_ item: Route.Setting) -> some View {
        
        AppCardView(shadow: .subtle) {
            
            HStack(spacing: Style.shared.spacing(.small)) {
                
                item
                    .icon
                    .view(renderingMode: .template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(item.tintColor.source())
                
                Text(item.displayName)
                    .appFont(with: .TITLE_4)
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
    
    private func versionItem() -> some View {
        
        VStack(alignment: .leading) {
            
            AppCardView(shadow: .subtle) {
                
                HStack(spacing: Style.shared.spacing(.small)) {
                    
                    Image(systemName: "iphone")
                        .appFont(with: .TITLE_4)
                        .foregroundStyle(Style.shared.accent.source())
                    
                    Text("App Version")
                        .appFont(with: .TITLE_4)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                    
                    Text(self.viewModel.appVersion)
                        .appFont(with: .HEADER_1)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                }
                
            }
            
        }
        .padding(.top, .large)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(SettingsViewModel.self)
    
    SettingsScreen(viewModel: viewModel)
        .withMockServices()
    
}
