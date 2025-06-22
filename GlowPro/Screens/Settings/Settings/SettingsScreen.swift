//
//  SettingsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/21/25.
//

import SwiftUI

struct SettingsScreen: View {
    
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
        
        StaggeredView(config: .init(delay: 0.1, maxDelay: 0, blurRadius: 0, offset: .init(width: 0, height: 100))) {
            
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
                
                Text(item.displayName)
                    .appFont(with: .TITLE_T5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .opacity(0.5)
                
            }
            .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        .asButton {
            
            self.viewModel
                .navigate(to: item)
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(SettingsViewModel.self)
    
    SettingsScreen(viewModel: viewModel)
        .withMockServices()
    
}
