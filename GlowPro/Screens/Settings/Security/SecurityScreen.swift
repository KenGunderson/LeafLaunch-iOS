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
        
        // On Change
        
        .onChange(of: self.viewModel.shouldReportScreenshots) { oldValue, newValue in
            
            guard !self.viewModel.firstReportScreenshotUpdate else { return }
            
            self.viewModel
                .toggleShouldReportScreenshots(shouldReportScreenshots: newValue)
            
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
        
        VStack(spacing: Style.shared.spacing(.large)) {
            
            Group {
                
                if !self.viewModel.isLoading {
                    
                    generalSection()
                    pinSection()
                    
                }
                
            }
            .transition(.offset(y: 200).combined(with: .opacity))
            
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        
    }
    
    private func generalSection() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(
                leadingTitle: "General",
                showDivider: true
            )
            
            HStack {
                
                Text("Report Screenshots")
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle(
                    "",
                    isOn: self.$viewModel.shouldReportScreenshots
                )
                
            }
            
            Text("Restrict all screenshots & get emailed whenever someone tries to take a screenshot while in the app.")
                .appFont(with: .BODY_2)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, -8)
            
        }
        
    }
    
    private func pinSection() -> some View {
        
        let title = "Secure Your Business Access"
        let subtitle = "Set up a secure 4-digit PIN to protect your business. This PIN is required to return to the main menu from your dashboard, ensuring only authorized users can exit."
        
        return VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(
                leadingTitle: "Limiting Access",
                showDivider: true
            )
            
            titleSubtitle(
                title: title,
                subtitle: subtitle
            )
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
    
    @ViewBuilder
    private func titleSubtitle(title: String,
                               subtitle: String) -> some View {
        
        Text(title)
            .appFont(with: .TITLE_4)
            .foregroundStyle(Style.shared.textColor(.title).source())
            .frame(maxWidth: .infinity, alignment: .leading)

        Text(subtitle)
            .appFont(with: .BODY_2)
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
