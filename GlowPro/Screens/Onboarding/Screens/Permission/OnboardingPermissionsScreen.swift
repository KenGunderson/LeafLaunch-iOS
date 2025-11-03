//
//  OnboardingPermissionsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/2/25.
//

import SwiftUI

struct OnboardingPermissionsScreen: GPView {
    
    @StateObject var viewModel: OnboardingPermissionsViewModel
    @State private var shouldAnimate: Bool = false
        
    var body: some View {
                
        VStack(alignment: .leading) {
            
            Text("Access")
                .appFont(with: .HEADER_5)
                .minimumScaleFactor(0.50)
                .padding(.horizontal, .medium)
            
            Text("This allows us to give you a better experience.")
                .appFont(with: .TITLE_5)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .multilineTextAlignment(.leading)
                .padding(.horizontal, .medium)
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                permissionView(
                    title: "Camera",
                    icon: "camera.fill",
                    isEnabled: self.viewModel.cameraPermission.shouldPromptForPermissions ? nil : self.viewModel.cameraPermission.permissionGranted) {
                        self.viewModel.permissionService.cameraPermissionService.requestPermissionIfNeeded()
                    }
                
                // Media
                
                permissionView(
                    title: "Photos",
                    icon: "photo.fill",
                    isEnabled: self.viewModel.mediaPermission.shouldPromptForPermissions ? nil : self.viewModel.mediaPermission.permissionGranted) {
                        self.viewModel.permissionService.mediaPermissionService.requestPermissionIfNeeded()
                    }
                
                // Push Notifications
                
                permissionView(
                    title: "Push Notifications",
                    icon: "message.fill",
                    isEnabled: self.viewModel.pushNotificationPermission.shouldPromptForPermissions ? nil : self.viewModel.pushNotificationPermission.permissionGranted) {
                        self.viewModel.permissionService.pushNotificationPermissionService.requestPermissionIfNeeded()
                    }
                
                // Tracking
                
                permissionView(
                    title: "Analytics",
                    icon: "lock.fill",
                    isEnabled: self.viewModel.trackingPermission.shouldPromptForPermissions ? nil : self.viewModel.trackingPermission.permissionGranted) {
                        self.viewModel.permissionService.appTrackingPermissionService.requestPermissionIfNeeded()
                    }
                
            }
            .padding(.top, .extraLarge)
            .padding(.horizontal, .medium)
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            
            withAnimation(.smooth(duration: 0.6, extraBounce: 0.2).delay(0.3)) {
                self.shouldAnimate = true
            }
            
        }
        .onDisappear {
            
            withAnimation(.smooth(duration: 0.6, extraBounce: 0.2).delay(0.3)) {
                self.shouldAnimate = false
            }
            
        }
        .opacity(self.shouldAnimate ? 1 : 0)
        .offset(y: self.shouldAnimate ? 0 : 200)
        .padding(.top, OnboardingScreen.headerHeight)
        .overlay {
            
            // We do this so the count updates the viewModel to redraw for permissions
            
            Text("\(viewModel.count)")
                .opacity(0)
            
        }
        
    }
    
    private func permissionView(title: String,
                                icon: String,
                                isEnabled: Bool?,
                                action: @escaping () -> ()) -> some View {
        
        var buttonTitle: String {
            if let isEnabled {
                return isEnabled ? "Allowed" : "Denied"
            }
            
            return "Authorize"
        }
        
        var buttonTitleColor: ColorSource {
            if isEnabled != nil {
                return Style.shared.textColor(.titleInverted)
            }
            
            return Style.shared.textColor(.title)
        }
        
        var buttonColor: ColorSource {
            if let isEnabled {
                return isEnabled ? Style.shared.accent : Style.shared.background(.error)
            }
            
            return Style.shared.background(.quaternary)
        }
        
        return HStack {
            
            Text("\(title)")
                .appFont(with: .TITLE_5)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            Spacer()
            
            CommonButton(
                title: buttonTitle,
                titleColor: buttonTitleColor,
                icon: .systemImage(icon),
                backgroundStyle: buttonColor,
                isEnabled: isEnabled ?? true,
                action: action
            )
            .frame(width: 180)
            
        }
        .compositingGroup()
        .geometryGroup()
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(OnboardingPermissionsViewModel.self)
    
    OnboardingPermissionsScreen(viewModel: viewModel)
        .withMockServices()
    
}
