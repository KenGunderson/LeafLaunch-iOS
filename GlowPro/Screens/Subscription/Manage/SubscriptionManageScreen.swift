//
//  SubscriptionManageScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/15/25.
//

import SwiftUI

struct SubscriptionManageScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: SubscriptionManageViewModel
    
    @State private var navigationService = NavigationService()
    
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
            
            // Alerts
            
                .withAlertService(.init(alertService: self.viewModel.alertService))
            
            // Sheets
            
                .adaptiveSheet(isPresented: self.$viewModel.shouldPresentCancelSubscriptionSheet) {
                    
                    SubscriptionCancelSheet {
                        
                        self.viewModel
                            .unsubscribe()
                        
                    } dismissAction: {
                        // Do Nothing
                    }
                    
                }
            
        }
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            navBar()
        } scrollViewContent: {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
                
                if let business = self.viewModel.business {
                    
                    let canCancelSubscription = business.stripeSubscription?.status == .active && !business.stripeHasPendingSubscriptionUpdate
                    let isPendingSubscriptionDowngrade = business.stripeHasPendingSubscriptionUpdate
                    let isCancellationPending = business.stripeSubscription?.status == .cancelled
                    
                    Group {
                        
                        if isPendingSubscriptionDowngrade {
                            pendingSubscriptionUpdateView()
                        }
                        
                        if isCancellationPending {
                            pendingCancellationView()
                        }
                        
                        activePlanView(business: business)
                        billingInformation(business: business)
                        mediaUsageView(business: business)
                        
                        if canCancelSubscription {
                            cancelSubscription()
                        }
                        
                        termsOfService()
                        
                    }
                    .transition(.offset(y: 300).combined(with: .opacity))
                    
                }
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .animation(.smooth, value: self.viewModel.business)
            
        }
        
    }
    
    private func navBar() -> some View {
        
        let closeButton = NavBarButton(style: .close) {
            dismiss()
        }
            .asAnyView()
        
        return NavBarView(
            title: "Manage Subscription",
            rightButtonView: closeButton
        )
        // TODO: - MAYBE ADD PADDING TOP MEDIUM?
    }
    
    @ViewBuilder
    private func activePlanView(business: Business) -> some View {
        
        if let subscription = business.stripeSubscription,
           let product = business.stripeSubscriptionProduct {
            
            let canUpdateSubscription = !business.stripeHasPendingSubscriptionUpdate
            
            let price = product.prices.filter({ $0.interval == subscription.stripeInterval && $0.amount > 0 }).first
            let normalizedPrice = (price?.amount ?? 0) / 100
                        
            let rawInterval = price?.interval ?? ""
            let interval = SubscriptionPaywallViewModel.Interval.createFromStripeName(rawInterval)
            
            let color = ActivityCategory.business.color
            
            SectionCardView(
                title: "Active Plan",
                icon: .systemImage("storefront.fill"),
                color: .color(color),
                headerActionTitle: canUpdateSubscription ? "Change Plan" : nil,
                headerAction: {
                    
                    self.navigationService
                        .modal(fullScreenCover: .subscriptionPaywall(
                            context: .update(
                                stripeSubscriptionId: subscription.stripeSubscriptionId,
                                selectedProduct: product,
                                selectedInterval: interval
                            ),
                            paywallItem: .GLOWPRO_PREMIUM_MONTHLY_SUBSCRIPTION)
                        )
                    
                }) {
                    
                    VStack(alignment: .leading,
                           spacing: Style.shared.spacing(.small2)) {
                        
                        HStack {
                            
                            Text(product.name)
                                .appFont(with: .HEADER_2)
                                .foregroundStyle(Style.shared.textColor(.body).source())
                                .lineLimit(1)
                            
                            HStack(spacing: 2) {
                                
                                Text(normalizedPrice, format: .currency(code: "USD"))
                                    .appFont(with: .HEADER_2)
                                    .foregroundStyle(color)
                                
                                Text("/ \(interval.description)")
                                    .appFont(with: .HEADER_2)
                                    .foregroundStyle(color)
                                
                            }
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                        }
                        
                        if let description = product.description {
                            
                            Text(description)
                                .appFont(with: .BODY_2)
                                .foregroundStyle(Style.shared.textColor(.body).source())
                            
                        }
                        
                        benefitsView(
                            subscription: subscription,
                            product: product
                        )
                        
                    }
                    
                }
            
        }
        
    }
    
    @ViewBuilder
    private func mediaUsageView(business: Business) -> some View {
        
        let color = ActivityCategory.media.color
        
        let usage = business.stripeSubscriptionOverageUsage ?? .init()
        let percentage = Float(usage.mediaUsagePercentage)
        
        SectionCardView(
            title: "Media Usage",
            icon: .systemImage("camera.fill"),
            color: .color(color)) {
                
                VStack(alignment: .leading,
                       spacing: Style.shared.spacing(.small2)) {
                    
                    VStack(spacing: Style.shared.spacing(.small)) {
                        
                        Text(usage.mediaUsagePercentage, format: .percent.precision(.fractionLength(0)))
                            .appFont(with: .TITLE_4)
                            .foregroundStyle(Style.shared.textColor(.body).source())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        ProgressBar(
                            value: .constant(percentage),
                            fillColor: .color(color)
                        )
                        .frame(height: 12)
                        .frame(maxHeight: 12)
                        .appShadow(.card)
                        
                    }
                    
                    HStack {
                        
                        Text("Used: \(usage.mediaUsed)")
                            .appFont(with: .TITLE_4)
                            .foregroundStyle(Style.shared.textColor(.body).source())
                        
                        Spacer()
                        
                        Text("Allowed: \(usage.mediaAllowed)")
                            .appFont(with: .TITLE_4)
                            .foregroundStyle(Style.shared.textColor(.body).source())
                        
                    }
                    
                    Text("Resets: \(Date.getNextBillingDate())")
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                    
                }
                       .padding(.top, -4)
                
            }
        
    }
    
    @ViewBuilder
    private func pendingSubscriptionUpdateView() -> some View {
        
        let color = GPColor.iconYellow
        
        SectionCardView(
            title: "Pending Subscription Update",
            icon: .systemImage("clock.fill"),
            color: .color(color)) {
                
                VStack(alignment: .leading,
                       spacing: Style.shared.spacing(.small2)) {
                    
                    Text("Your subscription is scheduled to downgrade on \(Date.getNextBillingDate()).")
                        .appFont(with: .TITLE_4)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("This change is waiting for the next billing cycle. You can continue using your current plan until then.")
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CommonButton(
                        title: "Undo Change",
                        backgroundStyle: .color(color)
                    ) {
                        
                        self.viewModel
                            .resubscribe()
                        
                    }
                    
                }
                
            }
        
    }
    
    @ViewBuilder
    private func pendingCancellationView() -> some View {
        
        let color = GPColor.iconRed
        
        SectionCardView(
            title: "Pending Cancellation",
            icon: .systemImage("trash.fill"),
            color: .color(color)) {
                
                VStack(alignment: .leading,
                       spacing: Style.shared.spacing(.small2)) {
                    
                    Text("Your subscription is scheduled to be cancelled on \(Date.getNextBillingDate()).")
                        .appFont(with: .TITLE_4)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("This change is waiting for the next billing cycle. You can continue using your current plan until then.")
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    CommonButton(
                        title: "Undo Change",
                        backgroundStyle: .color(color)
                    ) {
                        
                        self.viewModel
                            .resubscribe()
                        
                    }
                    
                }
                
            }
        
    }
    
    @ViewBuilder
    private func billingInformation(business: Business) -> some View {
        
        let color = ActivityCategory.location.color
        let rawInterval = business.stripeSubscription?.stripeInterval ?? ""
        let interval = SubscriptionPaywallViewModel.Interval.createFromStripeName(rawInterval)
        
        SectionCardView(
            title: "Billing Information",
            icon: .systemImage("info"),
            color: .color(color)) {
                
                VStack {
                    
                    Text("Next Renewal Date: \(Date.getNextBillingDate())")
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Billing Period: \(interval.description)")
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
            }
        
    }
    
    @ViewBuilder
    private func cancelSubscription() -> some View {
        
        CommonButton(
            style: .outline(lineWidth: 1.5),
            title: "Cancel Subscription",
            titleColor: Style.shared.background(.error),
            backgroundStyle: Style.shared.background(.error)
        ) {
            
            self.viewModel
                .shouldPresentCancelSubscriptionSheet = true
            
        }
        
    }
    
    @ViewBuilder
    private func benefitsView(subscription: StripeSubscription,
                              product: StripeSubscriptionProduct) -> some View {
        
        let color = ActivityCategory.business.color
        
        let totalNumberOfLocations = product.metadata?.totalNumberOfLocations ?? 0
        let totalNumberOfEmployees = product.metadata?.totalNumberOfEmployees ?? 0
        let totalNumberOfMedia = product.metadata?.totalNumberOfMedia ?? 0
        
        var stringNumberOfLocations: String {
            return totalNumberOfLocations == -1 ? "Unlimited" : "\(totalNumberOfLocations)"
        }
        
        var stringNumberOfEmployees: String {
            return totalNumberOfEmployees == -1 ? "Unlimited" : "\(totalNumberOfEmployees)"
        }
        
        var stringNumberOfMedia: String {
            return totalNumberOfMedia == -1 ? "Unlimited" : "\(totalNumberOfMedia)"
        }
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("Included In This Plan:")
                .foregroundStyle(Style.shared.textColor(.body).source())
                .appFont(with: .TITLE_4)
            
            // Location
            
            benefitView(
                icon: .systemImage("pin.fill"),
                title: "\(stringNumberOfLocations) Location\(pluralize(totalNumberOfLocations))",
                color: .color(color)
            )
            
            // Employee
            
            benefitView(
                icon: .image(.iconPerson, renderingMode: .template),
                title: "\(stringNumberOfEmployees) Additional Staff",
                color: .color(color)
            )
            
            // Media
            
            benefitView(
                icon: .systemImage("camera.fill"),
                title: "\(stringNumberOfMedia) Media Upload\(pluralize(totalNumberOfMedia))",
                color: .color(color)
            )
            
            // Notes
            
            benefitView(
                icon: .systemImage("doc.fill"),
                title: "Unlimited Notes & Forms",
                color: .color(color)
            )
            
        }
        
    }
    
    private func benefitView(icon: ImageSource,
                             title: String,
                             color: ColorSource) -> some View {
        
        HStack(spacing: Style.shared.spacing(.custom(6))) {
            
            icon
                .view()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .padding(.small)
                .foregroundStyle(color.source())
                .background(color.source(opacity: 0.12), in: .circle)
            
            Text(title)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .appFont(with: .TITLE_3)
                .lineLimit(nil)
            
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
                .push(.setting(.subscriptionTerms))
            
            return .handled
            
        }))
        .tint(Style.shared.accent.source())
        
    }
    
    private func pluralize(_ count: Int) -> String {
        return (count == 1) ? "" : "s"
    }
    
}

#Preview {
    
    @Previewable @State var showPaywall: Bool = true
    
    let viewModel = mockResolve(SubscriptionManageViewModel.self)
        .setup(businessId: MockModels.ID.business1)
    
    AppBaseView {
        
        CommonButton(title: "Show Manage Subscription") {
            showPaywall = true
        }
        .padding(.horizontal, .large)
        
    }
    .fullScreenCover(isPresented: $showPaywall) {
        
        SubscriptionManageScreen(viewModel: viewModel)
            .withMockServices()
        
    }
    
}
