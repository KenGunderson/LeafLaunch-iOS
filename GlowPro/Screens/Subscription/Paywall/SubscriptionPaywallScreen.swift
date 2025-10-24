//
//  SubscriptionPaywallScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/23/25.
//

import SwiftUI

struct SubscriptionPaywallScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) private var dismiss
    
    @State private var shouldAnimate: Bool = false
    
    @StateObject var viewModel: SubscriptionPaywallViewModel
    
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.shouldAnimate = true
                }
                
            }
        
            .onChange(of: self.viewModel.shouldDismiss) { _, newValue in
             
                guard newValue else { return }
                self.dismiss()
                
            }

        // Sheet
        
            .presentationCornerRadius(Style.shared.radius(.medium))
            .presentationDragIndicator(.hidden)
            .presentationBackground(Style.shared.background(.primary).source())
            .interactiveDismissDisabled(true)
        
        // Alerts
        
            .withAlertService(.init(alertService: self.viewModel.alertService))
        
        // Animations
        
            .animation(.snappy, value: self.shouldAnimate)
        
    }
    
    private func content() -> some View {
        
        AppBaseView(alignment: .top) {
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
                    
                    if self.shouldAnimate {
                        
                        header()
                            .transition(.offset(y: 300).combined(with: .opacity))
                        
                        benefitsView()
                            .transition(.opacity.animation(.smooth.delay(0.50)))
                        
                    }
                    
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .padding(.horizontal, .medium)
                
            }
            
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Image(.illustrationLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 32)
            
            Text("Capture. Organize. Grow.")
                .foregroundStyle(Style.shared.textColor(.title).source())
                .appFont(with: .HEADER_2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(.top, .large)
        
    }
    
    @ViewBuilder
    private func benefitsView() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                Text("Premium Access")
                    .foregroundStyle(Style.shared.accent.source())
                    .appFont(with: .HEADER_3)
                
                Text("Get exclusive access to all features, including ad-free browsing, offline listening, and early access to new releases.")
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .appFont(with: .BODY_3)
                
                let allBenefits = SubscriptionPaywallViewModel
                    .SubscriptionBenefit
                    .allCases
                
                ForEach(allBenefits, id: \.rawValue) { benefit in
                    benefitView(benefit)
                }
                .padding(.top, .small2)
                
            }
            .padding(.medium)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appBorder(
            cornerRadius: .medium,
            color: Style.shared.accent,
            lineWidth: 2.5
        )
        
    }
    
    @ViewBuilder
    private func benefitView(_ benefit: SubscriptionPaywallViewModel.SubscriptionBenefit) -> some View {
        
        HStack(spacing: Style.shared.spacing(.small2)) {
            
            benefit.icon
                .view()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(.small2)
                .foregroundStyle(Style.shared.accent.source())
                .background(Style.shared.accent.source(opacity: 0.20), in: .circle)
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(benefit.title)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .appFont(with: .TITLE_4)
                    .lineLimit(nil)
                
                Text(benefit.message)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .appFont(with: .BODY_2)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if self.shouldAnimate {
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                CommonButton(title: "Subscribe") {
                    
                    self.viewModel
                        .subscribe()
                    
                }
                
                Text("Not Now")
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .asButton {
                        self.dismiss()
                    }
                
            }
            .background(Style.shared.background(.primary).source())
            .padding(.horizontal, .large)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var showPaywall: Bool = true
    
    let viewModel = mockResolve(SubscriptionPaywallViewModel.self)
        .setup()
    
    AppBaseView {
    
        CommonButton(title: "Show Paywall") {
            showPaywall = true
        }
        .padding(.horizontal, .large)
        
    }
    .sheet(isPresented: $showPaywall) {
        
        SubscriptionPaywallScreen(viewModel: viewModel)
            .withMockServices()
        
    }
    
}
