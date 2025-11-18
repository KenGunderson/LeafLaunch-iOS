//
//  SubscriptionPaywallScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/23/25.
//

import SwiftUI

struct SubscriptionPaywallScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: SubscriptionPaywallViewModel
    
    @State private var navigationService = NavigationService()
    
    @State private var shouldAnimateContent: Bool = false
    @State private var shouldAnimateFooter: Bool = false
        
    let backgroundColor = Style.shared.background(.secondary).source()
    
    var body: some View {
        
        AppRootView(navigationService: self.$navigationService) {
            
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
            
            // On Change
            
                .onChange(of: self.viewModel.shouldDismiss) { _, newValue in
                    
                    guard newValue else { return }
                    self.dismiss()
                    
                }
            
                .onChange(of: self.viewModel.products) { oldValue, newValue in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.shouldAnimateContent = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.shouldAnimateFooter = true
                    }
                    
                }
            
            // Alerts
            
                .withAlertService(.init(alertService: self.viewModel.alertService))
            
            // Sheets
            
                .adaptiveSheet(
                    isPresented: self.$viewModel.shouldShowSubscriptionSuccessAlert,
                    backgroundStyle: Style.shared.background(.primary)
                ) {
                    
                    SubscriptionSuccessSheet {
                        dismiss()
                    }
                    
                }
            
            // Animations
            
                .animation(.snappy, value: self.viewModel.products)
                .animation(.snappy, value: self.shouldAnimateContent)
                .animation(.snappy, value: self.shouldAnimateFooter)
            
        }
        
    }
    
    private func content() -> some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.none)) {
                
                header()
                
                if self.shouldAnimateContent {
                    
                    if let paywallItem = self.viewModel.paywallItem {
                        
                        contentView(item: paywallItem)
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
            .scaledToFill()
            .frame(height: 250)
            .clipped()
            .stretchy()
            .gradientBlur(
                color: self.viewModel.extractedColors.first ?? .clear,
                alignment: .bottom,
                gradientDirection: .topToBottom,
                mask: .preset(.medium),
                heightStyle: .fixed(75)
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
    private func contentView(item: SubscriptionPaywallItem) -> some View {
                
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                Text(item.title)
                    .foregroundStyle(Style.shared.accent.source())
                    .appFont(with: .HEADER_3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(item.description)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .appFont(with: .BODY_3)
                
                CommonSegmentedControl(
                    selectedOption: self.$viewModel.selectedInterval,
                    options: SubscriptionPaywallViewModel.Interval.allCases,
                    selectedTextColor: Style.shared.textColor(.titleInverted)
                )
                .padding(.top, .small2)
                
                subscriptionProductList()
                    .padding(.top, .small2)
                
                termsOfService()
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
    private func subscriptionProductList() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            ForEach(self.viewModel.products, id: \.id) { product in
                
                SubscriptionProductView(
                    product: product,
                    interval: self.viewModel.selectedInterval ?? .monthly,
                    isSelected: product == self.viewModel.selectedProduct
                )
                .asButton {
                    
                    self.viewModel
                        .set(product: product)
                    
                }
                .animation(.bouncy, value: self.viewModel.selectedProduct)
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        let isReadOnly = self.viewModel.context == .view
        let closeButtonCopy = isReadOnly ? "Close" : "Not Now"
        
        if self.shouldAnimateFooter {
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                if !isReadOnly {
                    
                    CommonButton(
                        title: "Subscribe",
                        isEnabled: self.viewModel.isSubscribeButtonEnabled
                    ) {
                        
                        self.viewModel
                            .subscribe()
                        
                    }
                    
                }
                
                Text(closeButtonCopy)
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
    
    private func termsOfService() -> some View {
        
        AttributedText {
            
            Text("Feel free to read our ")
                .foregroundStyle(Style.shared.textColor(.body).source())
                .font(Style.shared.font(.BODY_2))
            
            Text("[Subscription Terms of Service](https://apple.com)")
                .font(Style.shared.font(.BODY_2))
                .foregroundStyle(Style.shared.accent.source())
                .underline()
            
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .multilineTextAlignment(.center)
        .environment(\.openURL, .init(handler: { url in
            
            self.navigationService
                .push(.setting(.termsOfService))
            
            return .handled
            
        }))
        .tint(Style.shared.accent.source())
        
    }
    
}

#Preview {
    
    @Previewable @State var showPaywall: Bool = true
    
    let viewModel = mockResolve(SubscriptionPaywallViewModel.self)
        .setup(
            context: .create,
            paywallItem: .GLOWPRO_PREMIUM_MONTHLY_SUBSCRIPTION
        )
    
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
