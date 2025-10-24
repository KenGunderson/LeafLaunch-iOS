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
    
    @State private var shouldAnimateContent: Bool = false
    @State private var shouldAnimateFooter: Bool = false
    
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
                    self.shouldAnimateContent = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.shouldAnimateFooter = true
                }
                
            }
        
        // On Change
        
            .onChange(of: self.viewModel.shouldDismiss) { _, newValue in
             
                guard newValue else { return }
                self.dismiss()
                
            }

        // Sheet
        
            .presentationCornerRadius(Style.shared.radius(.large))
            .presentationDragIndicator(.hidden)
            .presentationBackground(Style.shared.background(.primary).source())
            .interactiveDismissDisabled(true)
        
        // Alerts
        
            .withAlertService(.init(alertService: self.viewModel.alertService))
        
        // Animations
        
            .animation(.snappy, value: self.shouldAnimateContent)
            .animation(.snappy, value: self.shouldAnimateFooter)
        
    }
    
    private func content() -> some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.none)) {
                
                header()
                
                if self.shouldAnimateContent {
                    
                    benefitsView()
                        .offset(y: -24)
                        .transition(.offset(y: 300).combined(with: .opacity))
                    
                }
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .background(Style.shared.background(.secondary).source())
            .padding(.bottom, 86)
            
        }
        .ignoresSafeArea()
        .background(alignment: .top) {
            
            Color(hex: "a5d5b5")
                .frame(height: 300)
                .offset(y: 0)
                .ignoresSafeArea()
            
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        .background(Style.shared.background(.secondary).source())
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        Image(.illustrationWelcome)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                                
                VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
        
                    Image(.illustrationLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
        
                    Text("Capture. Organize. Grow.")
                        .foregroundStyle(Style.shared.textColor(.titleInverted).source())
                        .appFont(with: .HEADER_2)
                        .frame(maxWidth: .infinity, alignment: .leading)
        
                }
                .padding(.horizontal, .medium)
                .padding(.bottom, .custom(28))
                .background {
                    
                    LinearGradient(
                        colors: [
                            
                            Color(hex: "a5d5b5"),
                            Color(hex: "a5d5b5").opacity(0.9),
                            Color.clear
                            
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    
                }
                
            }
        
    }
    
    @ViewBuilder
    private func benefitsView() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                HStack {
                    
                    Text("Premium Access")
                        .foregroundStyle(Style.shared.accent.source())
                        .appFont(with: .HEADER_3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("$29.99")
                        .foregroundStyle(Style.shared.accent.source())
                        .appFont(with: .HEADER_4)
                    
                }
                
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Style.shared.background(.secondary).source())
        .clipShape(
            .rect(
                cornerRadii: .init(
                    topLeading: 24,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 24
                )
            )
        )
        .compositingGroup()
        
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
        
        if self.shouldAnimateFooter {
            
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
            .padding(.horizontal, .large)
            .padding(.top, .small)
            .frame(maxWidth: .infinity)
            .background(Style.shared.background(.secondary).source())
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
    .fullScreenCover(isPresented: $showPaywall) {
        
        SubscriptionPaywallScreen(viewModel: viewModel)
            .withMockServices()
        
    }
    
}
