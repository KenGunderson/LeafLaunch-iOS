//
//  BusinessSettingsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/20/25.
//

import SwiftUI
import Charts

struct BusinessSettingsScreen: GPView {
    
    @StateObject var viewModel: BusinessSettingsViewModel
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
                .loadData()
            
        }
        
        // On Change
        
        .onChange(of: self.viewModel.shouldReportScreenshots) { oldValue, newValue in
                        
            self.viewModel
                .set(shouldReportScreenshots: newValue)
            
        }
        
        .onChange(of: self.viewModel.shouldHideScreenshots) { oldValue, newValue in
            
            guard !self.viewModel.firstHideScreenshotUpdate else { return }
            
            self.viewModel
                .set(shouldHideScreenshots: newValue)
            
        }
        
        .onChange(of: self.viewModel.allowsOverages) { oldValue, newValue in
                        
            self.viewModel
                .set(allowsOverages: newValue)
            
        }
        
        // Animations
        
        .animation(.spring, value: self.viewModel.hasBusinessPin)
        
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "Business Settings",
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
                    subscriptionSection()
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
            
            // Hide Screenshots
            
            HStack(spacing: 0) {
                
                VStack(spacing: Style.shared.spacing(.extraSmall)) {
                    
                    
                    Text("Block Screenshots")
                        .appFont(with: .TITLE_4)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Disable screenshots across all devices and users to keep sensitive information protected.")
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
                Toggle(
                    "",
                    isOn: self.$viewModel.shouldHideScreenshots
                )
                .fixedSize(horizontal: true, vertical: false)
                
            }
            
            HStack(spacing: 0) {
                
                // Report Screenshots
                
                VStack(spacing: Style.shared.spacing(.extraSmall)) {
                    
                    HStack {
                        
                        Text("Report Screenshots")
                            .appFont(with: .TITLE_4)
                            .foregroundStyle(Style.shared.textColor(.title).source())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    
                    Text("Receive an email whenever anyone attempts a screenshot while inside the app.")
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
                Toggle(
                    "",
                    isOn: self.$viewModel.shouldReportScreenshots
                )
                .fixedSize(horizontal: true, vertical: false)
                
            }
            
        }
        
    }
    
    private func subscriptionSection() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(
                leadingTitle: "Subscription",
                showDivider: true
            )
            
            // Allows Overages
            
            HStack(spacing: 0) {
            
                VStack(spacing: Style.shared.spacing(.extraSmall)) {
                    
                    Text("Allow Data Overage Charges")
                        .appFont(with: .TITLE_4)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(.infinity)
                    
                    Text("Continue adding media even after your monthly limit is reached. Additional charges will apply. When this toggle is off, media uploads stop immediately once you hit your limit.")
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
                Toggle(
                    "",
                    isOn: self.$viewModel.allowsOverages
                )
                .fixedSize(horizontal: true, vertical: false)
                
            }
            
        }
        
    }
    
    private func pinSection() -> some View {
        
        let title = "Dashboard Lock"
        let subtitle = "Create a 4-digit PIN to keep your owner space safe and private. Staff can’t access your business dashboard or owner settings without it."
        
        return VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(
                leadingTitle: "Security",
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
                                .loadData()
                            
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
            
        BusinessSettingsScreen(
            viewModel: mockResolve(BusinessSettingsViewModel.self)
        )
        
    }
    .withMockServices()
    
}
