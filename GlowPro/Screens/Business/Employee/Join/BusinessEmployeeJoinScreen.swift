//
//  BusinessEmployeeJoinScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/13/25.
//

import SwiftUI

struct BusinessEmployeeJoinScreen: GPView {
    
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessEmployeeJoinViewModel
    
    var body: some View {
        
        content()
        
        // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            .onAppear {
                
                self.tabBarNavigationService
                    .shouldShowTabBar(false)
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            fields()
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
            title: "Join Business",
            rightButtonView: closeButton
        )
        .padding(.top, Style.shared.spacing(.medium))
        
    }
    
    
    private func fields() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            // Businesses
            
            sectionTitle("Enter Your Pin & Join a Business")
            codeView()
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func codeView() -> some View {
        
        Text("Insert Code View Here")
        
    }
    
    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        
        Text(title)
            .foregroundStyle(Style.shared.textColor(.title).source())
            .appFont(with: .TITLE_T8)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessEmployeeJoinViewModel.self)
    
    BusinessEmployeeJoinScreen(viewModel: viewModel)
        .withMockServices()
    
}
