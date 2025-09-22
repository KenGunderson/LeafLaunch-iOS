//
//  SecurityScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/20/25.
//

import SwiftUI
import Charts

struct SecurityScreen: GPView {
    
    @StateObject var viewModel: SecurityViewModel
    @Environment(NavigationService.self) private var navigationService
    
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
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
        .task {
            
            self.viewModel
                .loadDataIfNeeded()
            
        }
        
        // Animations
        
        .animation(.spring, value: self.viewModel.hasBusinessPin)
        
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "Security",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            Group {
                
                if !self.viewModel.isLoading {
                    
                    titleSubtitle()
                        .background(Style.shared.background(.primary).source())
                    
                    if self.viewModel.hasBusinessPin {
                        businessPin()
                    }
                    
                    setChangePinButton()
                        .padding(.top, .extraSmall)
                    
                    if self.viewModel.hasBusinessPin {
                        removePinButton()
                    }
                    
                }
                
            }
            .transition(.offset(y: 200).combined(with: .opacity))
            
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        
    }
    
    @ViewBuilder
    private func titleSubtitle() -> some View {
        
        Text("Secure Your Business Access")
            .appFont(with: .TITLE_5)
            .foregroundStyle(Style.shared.textColor(.title).source())
            .frame(maxWidth: .infinity, alignment: .leading)

        Text("Set up a secure 4-digit PIN to protect your business. This PIN is required to return to the main menu from your dashboard, ensuring only authorized users can exit.")
            .appFont(with: .BODY_3)
            .foregroundStyle(Style.shared.textColor(.body).source())
            .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func businessPin() -> some View {
        
        AttributedText {
            
            Text("Your Pin: ")
                .foregroundStyle(Style.shared.textColor(.title).source())
                .font(Style.shared.font(.HEADER_4))
            
            Text(self.viewModel.businessPin)
                .foregroundStyle(Style.shared.accent.source())
                .font(Style.shared.font(.HEADER_4))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.asymmetric(
            insertion: .offset(y: 200).combined(with: .opacity),
            removal: .opacity
        ))
        
    }
    
    @ViewBuilder
    private func setChangePinButton() -> some View {
        
        let buttonTitle = self.viewModel.hasBusinessPin ? "Change PIN" : "Set PIN"
        
        CommonButton(title: buttonTitle,
                     icon: .systemImage("lock.fill")) {
            
            self.navigationService
                .modal(sheet: .securityPin(
                    context: .create,
                    businessId: self.viewModel.businessId ?? "",
                    completion: { success in
                        
                        if success {
                            
                            self.viewModel
                                .loadDataIfNeeded()
                            
                        }
                        
                    }))
            
        }
        
    }
    
    private func removePinButton() -> some View {
        
        CommonButton(title: "Remove Pin",
                     icon: .systemImage("trash.fill"),
                     backgroundStyle: Style.shared.background(.error)
        ) {
            
            self.viewModel
                .removePin()
            
        }
        .transition(.asymmetric(
            insertion: .offset(y: 200).combined(with: .opacity),
            removal: .opacity
        ))
                    
    }
    
}

#Preview {
    
    AppRootView(navigationService: .constant(NavigationService())) {
            
        SecurityScreen(
            viewModel: mockResolve(SecurityViewModel.self)
        )
        
    }
    .withMockServices()
    
}
