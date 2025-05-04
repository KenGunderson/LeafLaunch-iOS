//
//  MultiAlertView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/5/24.
//

import SwiftUI

struct MultiAlertView<Content: View>: View {
    
    @StateObject var alertService: ObservableAlertServiceWrapper
    
    let content: Content
    
    @State private var currentAlert: Alert?
    
    init(alertService: ObservableAlertServiceWrapper,
         @ViewBuilder content: () -> Content) {
        
        self._alertService = .init(wrappedValue: alertService)
        self.content = content()
        
    }
    
    var body: some View {
        
        ZStack {
            
            // Content
            
            content

            // Alpha View
            
            if !alertService.alerts.isEmpty {
                alphaView()
            }
            
            // Current Alert View
                        
            if let currentAlert,
               currentAlert == self.alertService.alerts.last {
                
                viewForAlertStyle(alert: currentAlert)
                    .id(self.currentAlert?.id ?? "")
                    .zIndex(2)
                                    
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .onChange(of: self.alertService.alerts) { oldValue, newValue in
            
            withAnimation(.spring(duration: 0.3)) {
                self.currentAlert = newValue.last
            }
            
        }
        .onChange(of: self.alertService.requestedToDeleteAlert) { oldValue, newValue in
            
            guard newValue else { return }
            
            if newValue {
                dismiss()
            }
            
            self.alertService
                .setRequestToDeleteAlert(false)
            
        }
        
    }
    
    private func alphaView() -> some View {
        
        Color.black
            .opacity(0.3)
            .ignoresSafeArea()
            .transition(.opacity.animation(.smooth(duration: 0.5)))
            .zIndex(1)
        
    }
    
    @ViewBuilder
    private func viewForAlertStyle(alert: Alert) -> some View {
        
        switch alert.alert {
        case .appAlert(let config):
            
            appAlertView(
                alert: alert,
                config: config
            )
            
        case .card(let config):
            
            appCardView(
                alert: alert,
                config: config
            )
            
        case .textfield(let config, let action):
            
            appAlertTextFieldView(
                alert: alert,
                config: config,
                action: action
            )
            
        case .loadingIndicator(let config):
            
            appAlertLoadingView(
                alert: alert,
                config: config
            )
            
        case .simpleLoadingIndicator:
            
            appAlertLoadingView(
                alert: alert,
                config: .init(loadStyle: .progressView(title: "Loading"))
            )
        
        case .enviornmentAlert(let enviornmentAlertConfig):
            
            appCustomCardView(customAlert: enviornmentAlertConfig)
            
        }
        
    }
    
    private func appAlertView(alert: Alert,
                              config: AppAlertConfig) -> some View {
        
        let transition = AnyTransition
            .scale
            .combined(with: .opacity)
        
        return AppAlertView(alert: config) {
            
            dismiss()
            
        }
        .appShadow()
        .transition(transition)
        
    }
    
    private func appAlertTextFieldView(alert: Alert,
                                       config: AppAlertConfig,
                                       action: @escaping (String) -> ()) -> some View {
        
        let transition = AnyTransition
            .scale
            .combined(with: .opacity)
        
        return AlertTextFieldView(alert: config) { text in
            
            action(text)
            
        } dismissAction: {
            
            dismiss()
            
        }
        .transition(transition)
        
    }
    
    private func appCardView(alert: Alert,
                             config: AppCardConfig) -> some View {
        
        ZStack {
            
            Color.backgroundTappable
                .contentShape(.rect)
                .onTapGesture {
                    if config.shouldDismissOnOutsideTouch {
                        dismiss()
                    }
                }
            
            VStack {
                
                Spacer()
                
                AppAlertCardView(config: config) {
                    dismiss()
                }
                .customSafeAreaPadding(for: .bottom)
                
            }
            .ignoresSafeArea()
        
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        
    }
    
    private func appCustomCardView(customAlert: Alert.EnviornmentAlertConfig) -> some View {
        
        ZStack {
            
            Color.backgroundTappable
                .contentShape(.rect)
            
            VStack {
                
                Spacer()
                
                switch customAlert.style {
                case .noNetwork(let action):
                    
                    buildNoNetworkCustomModalCardView {
                        
                        action()
                        dismiss()
                        
                    }
                    
                case .healthCheck(let action):
                    
                    buildHealthCheckCustomModalCardView {
                        
                        action()
                        dismiss()
                        
                    }
                    
                case .forceUpdate(let action):
                    
                    buildForceUpdateCustomModalCardView {
                        
                        action()
                        dismiss()
                        
                    }
                    
                }
                
            }
            .ignoresSafeArea()
        
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        
    }
    
    private func appAlertLoadingView(alert: Alert,
                                     config: AppLoadingConfig) -> some View {
        
        let transition = AnyTransition
            .scale
            .combined(with: .opacity)
        
        switch config.loadStyle {
        case .progressView(let title):
            
            if title == "Linear Loading" {
                
                return ProgressView(value: 0.8)
                    .foregroundStyle(Style.shared.accent.source())
                    .transition(transition)
                    .padding(Style.shared.spacing(.extraLarge))
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: Style.shared.radius(.medium)))
                    .progressViewStyle(.linear)
                    .padding(.horizontal, 64)
                
            } else {
                
                return ProgressView(title)
                    .foregroundStyle(Style.shared.accent.source())
                    .transition(transition)
                    .padding(Style.shared.spacing(.extraLarge))
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: Style.shared.radius(.medium)))
                    .progressViewStyle(.circular)
                
            }
        }
        
    }
    
    private func buildNoNetworkCustomModalCardView(action: @escaping () -> ()) -> some View {
        
        EnvironmentAlertView(
            title: "No Network",
            message: "You seem to me be missing your internet connection.",
            image: Image(systemName: "wifi.slash"),
            imageColor: Style.shared.accent,
            buttonTitle: "Try Again",
            buttonColor: Style.shared.accent,
            action: action
        )
        
    }
    
    private func buildHealthCheckCustomModalCardView(action: @escaping () -> ()) -> some View {
        
        EnvironmentAlertView(
            title: "API Down 🙃",
            message: "We seem to be experiences technical difficulties. Please try again later.",
            image: Image(systemName: "stethoscope.circle.fill"),
            imageColor: .color(.red),
            buttonTitle: "Try Again",
            buttonColor: .color(.red),
            action: action
        )
        
    }
    
    private func buildForceUpdateCustomModalCardView(action: @escaping () -> ()) -> some View {
        
        EnvironmentAlertView(
            title: "Old App Version",
            message: "Your app version is too old. Please go to the store and download the latest build.",
            image: Image(systemName: "building.2.crop.circle.fill"),
            imageColor: .color(.blue),
            buttonTitle: "Update Now",
            buttonColor: .color(.blue),
            action: action
        )
        
    }
    
    private func dismiss() {
        
        let localAlert = self.currentAlert
        
        withAnimation(.spring(duration: 0.3)) {
            self.currentAlert = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            if let localAlert {
                
                self.alertService
                    .dismissAlert(localAlert)
                
                self.alertService
                    .setRequestToDeleteAlert(false)
                
            }
            
        }
        
    }
    
}

struct AlertModifier: ViewModifier {
    
    @ObservedObject var alertService: ObservableAlertServiceWrapper
    
    func body(content: Content) -> some View {
        
        MultiAlertView(alertService: alertService) {
            content
        }
        
    }
    
}

extension View {
    
    func withAlertService(_ alertService: ObservableAlertServiceWrapper) -> some View {
        self.modifier(AlertModifier(alertService: alertService))
    }
    
}
