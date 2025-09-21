//
//  SecurityPinInputScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/15/25.
//
//

import SwiftUI

struct SecurityPinInputScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: SecurityPinInputViewModel
    
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
        
            .onChange(of: self.viewModel.shouldDismiss) { _, newValue in
             
                guard newValue else { return }
                self.dismiss()
                
            }
        
        // Tap
        
            .hideKeyboard()
        
        // Sheet
        
            .presentationCornerRadius(Style.shared.radius(.medium))
            .presentationDragIndicator(.hidden)
            .presentationBackground(Style.shared.background(.primary).source())
            .interactiveDismissDisabled(true)
        
        // Alerts
        
            .withAlertService(.init(alertService: self.viewModel.alertService))
        
    }
    
    private func content() -> some View {
        
        AppBaseView(alignment: .top) {
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                navBar()
                fields()
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    private func navBar() -> some View {
        
        let closeButton = NavBarButton(style: .close) {
            dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Security",
            rightButtonView: closeButton
        )
        .padding(.top, self.isPresented ? .medium : .none)
        
    }
    
    private func fields() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.large)) {
            
            header()
            
            CommonCodeInputView(
                codeInput: self.$viewModel.pinText,
                maxCharacterCount: 4,
                maxWidthPerCharacter: 80,
                characterHeight: 80
            )
            .centerHorizontally()
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func bottomBar() -> some View {
        
        CommonButton(
            title: "Continue",
            isEnabled: self.viewModel.isContinueButtonEnabled
        ) {
            
            self.viewModel
                .handleContinue()
            
        }
        .padding(.horizontal, .large)
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            Text(self.viewModel.context.title)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .appFont(with: .TITLE_6)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            
            Text(self.viewModel.context.message)
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
    
    let viewModel = mockResolve(SecurityPinInputViewModel.self)
        .setup(
            context: .validate,
            businessId: MockModels.ID.business1) { success in
                
            }
    
    SecurityPinInputScreen(viewModel: viewModel)
        .withMockServices()
    
}
