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
            .frame(height: 300)
            .clipped()
            .stretchy()
            .gradientBlur(
                color: self.viewModel.extractedColors.first ?? .red,
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
                subscriptionProductView(product)
            }
            
        }
        
    }
    
    @ViewBuilder
    private func subscriptionProductView(_ product: StripeSubscriptionProduct) -> some View {
        
        let selectedInterval = self.viewModel.selectedInterval
        let isSelected = self.viewModel.selectedProduct == product
        let metadata = product.metadata ?? .init()
        
        let price = product
            .prices
            .filter({ $0.interval == selectedInterval?.stripeName })
            .first
        
        let normalizedPrice = (price?.amount ?? 0) / 100
        
        let backgroundColor: ColorSource = isSelected
            ? .color(Style.shared.accent.asColor!.opacity(0.15))
            : .color(Color.clear)
        
        let borderColor: ColorSource = isSelected
            ? Style.shared.accent
            : Style.shared.background(.quaternary)
        
        AppCardView(backgroundStyle: backgroundColor) {
            
            VStack(
                alignment : .leading,
                spacing : Style.shared.spacing(.small)
            ) {
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28)
                    .foregroundStyle(borderColor.source())
                
                HStack {
                    
                    Text(product.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: Style.shared.spacing(.custom(2))) {
                        
                        Text(normalizedPrice, format: .currency(code: "USD"))
                            .contentTransition(.numericText(value: Double(normalizedPrice)))
                        
                        Text("/ \(selectedInterval?.stripeName.capitalized ?? "")")
                            .contentTransition(.numericText())
                        
                    }
                    
                }
                .appFont(with: .TITLE_6)
                .foregroundStyle(Style.shared.textColor(.title).source())
                
                if let description = product.description {
                    
                    Text(description)
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
                benefitsView(metadata)
                    .padding(.top, .small)
                
            }
            
        }
        .background(.backgroundTappable)
        .appBorder(
            cornerRadius: .small2,
            color: borderColor,
            lineWidth: 2.5
        )
        .asButton {
            
            self.viewModel
                .set(product: product)
            
        }
        .animation(.bouncy, value: self.viewModel.selectedProduct)
        
    }
    
    @ViewBuilder
    private func benefitsView(_ data: StripeSubscriptionProduct.Metadata) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            let totalNumberOfLocations: Int? = data.totalNumberOfLocations ?? 0
            let totalNumberOfEmployees: Int? = data.totalNumberOfEmployees
            let totalNumberOfMedia: Int? = data.totalNumberOfMedia
            
            var stringNumberOfLocations: String {
                return totalNumberOfLocations == -1 ? "Unlimited" : "\(totalNumberOfLocations ?? 0)"
            }
            
            var stringNumberOfEmployees: String {
                return totalNumberOfEmployees == -1 ? "Unlimited" : "\(totalNumberOfEmployees ?? 0)"
            }
            
            var stringNumberOfMedia: String {
                return totalNumberOfMedia == -1 ? "Unlimited" : "\(totalNumberOfMedia ?? 0)"
            }
            
            // Location
            
            benefitView(
                icon: .systemImage("pin"),
                title: "You receive \(stringNumberOfLocations)(s) locations"
            )
            
            // Employee
            
            benefitView(
                icon: .image(.iconPerson, renderingMode: .template),
                title: "You can have up to \(stringNumberOfEmployees) employees"
            )
            
            // Media
            
            benefitView(
                icon: .image(.iconAlbum, renderingMode: .template),
                title: "You can take up to \(stringNumberOfMedia) media per month"
            )
            
        }
        
    }
    
    private func benefitView(icon: ImageSource,
                             title: String) -> some View {
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            icon
                .view()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .padding(.small)
                .foregroundStyle(Style.shared.accent.source())
                .background(Style.shared.accent.source(opacity: 0.20), in: .circle)
            
            Text(title)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .appFont(with: .TITLE_3)
                .lineLimit(nil)
            
        }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if self.shouldAnimateFooter {
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                CommonButton(
                    title: "Subscribe",
                    isEnabled: self.viewModel.isSubscribeButtonEnabled
                ) {
                    
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
        .setup(paywallItem: .GLOWPRO_PREMIUM_MONTHLY_SUBSCRIPTION)
    
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
