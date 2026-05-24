//
//  OnboardingPermissionsScreen.swift
//  Grimoire
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
                        self.viewModel.requestCameraPermissionIfNeeded()
                    }

                // Media

                permissionView(
                    title: "Photos",
                    icon: "photo.fill",
                    isEnabled: self.viewModel.mediaPermission.shouldPromptForPermissions ? nil : self.viewModel.mediaPermission.permissionGranted) {
                        self.viewModel.requestMediaPermissionIfNeeded()
                    }

                // Push Notifications

                permissionView(
                    title: "Notifications",
                    icon: "message.fill",
                    isEnabled: self.viewModel.pushNotificationPermission.shouldPromptForPermissions ? nil : self.viewModel.pushNotificationPermission.permissionGranted) {
                        self.viewModel.requestNotificationPermissionIfNeeded()
                    }

                // Tracking

                permissionView(
                    title: "Analytics",
                    icon: "lock.fill",
                    isEnabled: self.viewModel.trackingPermission.shouldPromptForPermissions ? nil : self.viewModel.trackingPermission.permissionGranted) {
                        self.viewModel.requestTrackingPermissionIfNeeded()
                    }

                // Microphone

                permissionView(
                    title: "Microphone",
                    icon: "mic.fill",
                    isEnabled: self.viewModel.microphonePermission.shouldPromptForPermissions ? nil : self.viewModel.microphonePermission.permissionGranted) {
                        self.viewModel.requestMicrophonePermissionIfNeeded()
                    }

                // Speech Recognition

                permissionView(
                    title: "Speech Recognition",
                    icon: "waveform.and.mic",
                    isEnabled: self.viewModel.speechRecognitionPermission.shouldPromptForPermissions ? nil : self.viewModel.speechRecognitionPermission.permissionGranted) {
                        self.viewModel.requestSpeechRecognitionPermissionIfNeeded()
                    }

                AttributedText {

                    Text("Need to update your permissions? You can always update your permissions by navigating to settings and tapping ")
                        .font(Style.shared.font(.BODY_3))
                        .foregroundStyle(Style.shared.textColor(.body).source())

                    Text("Update Permissions.")
                        .foregroundStyle(Style.shared.accent.source())
                        .font(Style.shared.font(.HEADER_1))

                }
                .frame(maxWidth: .infinity, alignment: .center)

            }
            .padding(.top, .large2)
            .padding(.horizontal, .medium)

        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onFirstAppear { [weak viewModel] in

            viewModel?
                .handleFirstAppear()

        }
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

            return "Next"
        }

        var buttonTitleColor: ColorSource {
            if isEnabled != nil {
                return Style.shared.textColor(.titleInverted)
            }

            return Style.shared.textColor(.title)
        }

        var buttonColor: ColorSource {
            if let isEnabled {
                return isEnabled ? Style.shared.accent : Style.shared.palette(.error)
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
