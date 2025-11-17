//
//  SubscriptionManageScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/15/25.
//

import SwiftUI

struct SubscriptionManageScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: SubscriptionManageViewModel
    
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
        
        // Alerts
        
            .withAlertService(.init(alertService: self.viewModel.alertService))
        
        // Animations
        
            .animation(.snappy, value: self.viewModel.business)
        
    }
    
    private func content() -> some View {
        
        AppBaseView(alignment: .top) {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
                
                navBar()
                
                if let business = self.viewModel.business {
                    
                    Text("Current Subscription:")
                        .appFont(with: .TITLE_5)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                    if let subscription = business.subscription,
                       let subscriptionProduct = business.stripeSubscriptionProduct {
                        
                        SubscriptionProductView(
                            product: subscriptionProduct,
                            interval: SubscriptionPaywallViewModel.Interval(rawValue: subscription.stripeInterval) ?? .monthly,
                            isSelected: true
                        )
                        
                    }
                    
                    Group {
                        
                        CommonButton(title: "Unsubscribe") {
                            
                            self.viewModel
                                .unsubscribe()
                            
                        }
                        
                        CommonButton(title: "Resubscribe") {
                            
                            self.viewModel
                                .resubscribe()
                            
                        }
                        
                        CommonButton(title: "Update Subscription") {
                            
                            self.viewModel
                                .upgradeOrDowngrade(
                                    priceId: "price_1STbpWDEpnIa6l7R995RByZm"
                                )
                            
                        }
                        
                    }
                    
                }
                
            }
            .padding(.horizontal, .large)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            
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
        .padding(.top, .medium)
        
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
