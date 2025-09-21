//
//  SettingsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/21/25.
//

import SwiftUI
import StoreKit

struct SettingsScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    
    @StateObject var viewModel: SettingsViewModel
    @State private var navigationService = NavigationService()
        
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
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
            
            // OnChange
            
            .onChange(of: self.viewModel.shouldDismiss) { _, newValue in
                
                guard newValue else { return }
                self.dismiss()
                
            }
            
            .onChange(of: self.viewModel.shouldShowRateAppAlert) { oldValue, newValue in
                
                guard newValue else { return }
                self.requestReview()
                
            }
            
            // Mail Composer
            
            .emailComposer(
                isPresented: self.$viewModel.shouldShowMailComposer,
                emailData: self.viewModel.emailData
            )
            
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
    
    
    private func content() -> some View {
        
        var settings: [Route.Setting] = Route.Setting.allCases
        
        if !self.viewModel.shouldShowSecuritySetting {
            settings.removeAll { $0 == .security }
        }
        
        let groups = Dictionary(grouping: settings, by: { $0.category })
        let config = Constants.StaggerAnimation.config(interitemSpacing: 8)
        
        return StaggeredView(config: config) {
            
            if !self.viewModel.isLoading {
                
                ForEach(groups.keys.sorted(), id: \.self) { category in
                    
                    let isFirst = (category == "Account")
                    let isLogout = (category == "Logout")
                    
                    if !isLogout {
                        
                        SectionView(leadingTitle: category.capitalized)
                            .padding(.bottom, .extraSmall)
                            .padding(.top, isFirst ? .none : .small)
                        
                    }
                    
                    ForEach(groups[category] ?? [], id: \.self) { item in
                        
                        settingItem(item)
                            .padding(.top, isLogout ? 24 : 0)
                        
                    }
                    
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
