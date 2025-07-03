//
//  OnboardingPermissionsScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/2/25.
//

import SwiftUI

struct OnboardingPermissionsScreen: GPView {
    
    @State private var shouldAnimate: Bool = false
    
    let permissionService: PermissionsServiceProtocol
    
    var body: some View {
                
        VStack(alignment: .leading) {
            
            Text("Access")
                .appFont(with: .BILLBOARD_B1)
                .minimumScaleFactor(0.50)
                .padding(.horizontal, .large)
            
            Text("This allows us to give you a better experience.")
                .appFont(with: .TITLE_T6)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .multilineTextAlignment(.leading)
                .padding(.horizontal, .large)
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                let cameraPermssion = self.permissionService.cameraPermissionService
                let mediaPermission = self.permissionService.mediaPermissionService
                let pushNotificationPermission = self.permissionService.pushNotificationPermissionService
                let appTrackingPermission = self.permissionService.appTrackingPermissionService
                
                permissionView(
                    title: "Camera",
                    icon: "camera.fill",
                    isEnabled: cameraPermssion.shouldPromptForPermissions ? nil : cameraPermssion.permissionGranted) {
                        self.permissionService.cameraPermissionService.requestPermissionIfNeeded()
                    }
                
                // Media
                
                permissionView(
                    title: "Photos",
                    icon: "photo.fill",
                    isEnabled: mediaPermission.shouldPromptForPermissions ? nil : mediaPermission.permissionGranted) {
                        self.permissionService.mediaPermissionService.requestPermissionIfNeeded()
                    }
                
                // Push Notifications
                
                permissionView(
                    title: "Push Notifications",
                    icon: "message.fill",
                    isEnabled: pushNotificationPermission.shouldPromptForPermissions ? nil : pushNotificationPermission.permissionGranted) {
                        self.permissionService.pushNotificationPermissionService.requestPermissionIfNeeded()
                    }
                
                // Tracking
                
                permissionView(
                    title: "Analytics",
                    icon: "lock.fill",
                    isEnabled: appTrackingPermission.shouldPromptForPermissions ? nil : appTrackingPermission.permissionGranted) {
                        self.permissionService.appTrackingPermissionService.requestPermissionIfNeeded()
                    }
                
            }
            .padding(.top, .extraLarge)
            .padding(.horizontal, .large)
            
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
                .appFont(with: .TITLE_T6)
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
        
    }
    
}

#Preview {
    
    let permissionsService = mockResolve(PermissionsServiceProtocol.self)
    
    OnboardingPermissionsScreen(permissionService: permissionsService)
        .withMockServices()
    
}
