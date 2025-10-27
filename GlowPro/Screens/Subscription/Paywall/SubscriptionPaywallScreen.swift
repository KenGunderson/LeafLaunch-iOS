//
//  SubscriptionPaywallScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/23/25.
//

import SwiftUI

struct SubscriptionPaywallScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: SubscriptionPaywallViewModel
    
    @State private var shouldAnimateContent: Bool = false
    @State private var shouldAnimateFooter: Bool = false
        
    let backgroundColor = Style.shared.background(.secondary).source()
    
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
                    
                    if let paywallItem = self.viewModel.paywallItem {
                        
                        benefitsView(item: paywallItem)
                            .offset(y: -24)
                            .transition(.offset(y: 300).combined(with: .opacity))
                        
                    }
                    
                }
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .background(self.backgroundColor)
            .padding(.bottom, 86)
            
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        .background(self.backgroundColor)
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        self.viewModel
            .paywallItem
            .illustration
            .view()
            .aspectRatio(contentMode: .fill)
            .stretchy()
            .gradientBlur(
                color: self.viewModel.extractedColors.first ?? .red,
                alignment: .bottom,
                gradientDirection: .topToBottom,
                mask: .preset(.medium),
                heightStyle: .fixed(150)
            )
            .overlay(alignment: .bottom) {
                                
                VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
        
                    Image(.illustrationLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
        
                    Text(self.viewModel.paywallItem.tagline)
                        .foregroundStyle(Style.shared.textColor(.titleInverted).source())
                        .appFont(with: .HEADER_2)
                        .frame(maxWidth: .infinity, alignment: .leading)
        
                }
                .padding(.horizontal, .medium)
                .padding(.bottom, .custom(28))
                
            }
        
    }
    
    @ViewBuilder
    private func benefitsView(item: SubscriptionPaywallItem) -> some View {
                
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                HStack {
                    
                    Text(item.title)
                        .foregroundStyle(Style.shared.accent.source())
                        .appFont(with: .HEADER_3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(item.price, format: .currency(code: "USD"))
                        .foregroundStyle(Style.shared.accent.source())
                        .appFont(with: .HEADER_4)
                    
                }
                
                Text(item.description)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .appFont(with: .BODY_3)
                
                ForEach(item.benefits, id: \.title) { benefit in
                    benefitView(benefit)
                }
                .padding(.top, .small2)
                
            }
            .padding(.medium)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(self.backgroundColor)
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
    private func benefitView(_ benefit: SubscriptionPaywallItem.BenefitItem) -> some View {
        
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
            .background(self.backgroundColor)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var showPaywall: Bool = true
    
    let viewModel = mockResolve(SubscriptionPaywallViewModel.self)
        .setup(paywallItem: .GLOWPRO_ADD_LOCATION_MONTHLY)
    
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

