//
//  BusinessEmployeeJoinScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/13/25.
//

import SwiftUI

struct BusinessEmployeeJoinScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessEmployeeJoinViewModel
    
    var body: some View {
        
        content()
        
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
        
        // Tap
        
            .hideKeyboard()
        
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
        .scrollBounceBehavior(.basedOnSize)
        
    }
    
    private func navBar() -> some View {
        
        let closeButton = NavBarButton(style: .close) {
            dismiss()
        }
        .padding(.trailing, .small)
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
            .containerRelativeFrame(.vertical, { dimension, axis in
                return dimension / 2
            })
            .padding(.horizontal, .medium)
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
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
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            Text("Enter Your Pin & Join a Business")
                .foregroundStyle(Style.shared.textColor(.title).source())
                .appFont(with: .TITLE_6)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            
            Text("Use the 5 digit code provided to your business to join their account. You can find this code in your inbox.")
                .foregroundStyle(Style.shared.textColor(.body).source())
                .appFont(with: .BODY_4)
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
