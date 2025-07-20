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
        .safeAreaInset(edge: .bottom) {
            bottomBar()
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
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.large)) {
            
            // Businesses
            
            header()
            
            CommonCodeInputView(
                codeInput: self.$viewModel.codeText,
                maxCharacterCount: 5,
            )
            .padding(.horizontal, .medium)
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func codeView() -> some View {
        
        Text("Insert Code View Here")
        
    }
    
    private func bottomBar() -> some View {
        
        CommonButton(
            title: "Submit",
            isEnabled: self.viewModel.isSaveButtonEnabled
        ) {
            
        }
        .padding(.horizontal, .large)
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            Text("Enter Your Pin & Join a Business")
                .foregroundStyle(Style.shared.textColor(.title).source())
                .appFont(with: .TITLE_T8)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            
            Text("Use the 5 digit code provided to your business to join their account. You can find this code in your inbox.")
                .foregroundStyle(Style.shared.textColor(.body).source())
                .appFont(with: .BODY_B4)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessEmployeeJoinViewModel.self)
    
    BusinessEmployeeJoinScreen(viewModel: viewModel)
        .withMockServices()
    
}
