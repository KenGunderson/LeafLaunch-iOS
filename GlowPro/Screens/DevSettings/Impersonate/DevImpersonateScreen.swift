//
//  DevImpersonateScreen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 11/4/24.
//

import SwiftUI
import Charts

struct DevImpersonateScreen: View {
    
    @StateObject var viewModel: DevImpersonateViewModel
    @Environment(NavigationService.self) private var navigationService
    
    @FocusState var textFieldFocusState: Bool
            
    var body: some View {
        
        AppHeaderScrollView {
        
            headerView()
            
        } scrollViewContent: {
            
            content()
            
        }
        .safeAreaInset(edge: .bottom) {
            
            if let isImpersonating = viewModel.isImpersonating {
                bottomButtonView(isImpersonating: isImpersonating)
            }
            
        }
        
        // Lifecycle
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }

    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "Impersonate",
            subtitle: "Morph into a different user",
            leftButtonView: (
                BackButton {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    private func content() -> some View {
        
        LazyVStack(spacing: Style.shared.spacing(.medium)) {
            
            if let isImpersonating = viewModel.isImpersonating {
                infoView(isImpersonating: isImpersonating)
            }
            
            TextField(
                "Email",
                text: self.$viewModel.userToImpersonateEmail,
                prompt: Text("Email").foregroundStyle(Style.shared.textColor(.body).source())
            )
            .focused(self.$textFieldFocusState, equals: true)
            .appTextFieldStyle(
                text: self.viewModel.userToImpersonateEmail,
                hint: "Email",
                icon: nil,
                isFocused: self.textFieldFocusState
            )
            .textContentType(.emailAddress)
            .appOnTapGesture {
                self.textFieldFocusState = true
            }
            
            Text("""
            When impersonating a user:\n
            1. You receive a new authentication token, allowing the system to recognize you as that user.\n
            2. Your device information is excluded from their account data in the database.\n
            3. All analytics events are blocked during impersonation.\n
            """)
            .appFont(with: .BODY_B5)
            .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        .animation(
            .bouncy(duration: 0.8),
            value: self.viewModel.isImpersonating
        )
        
    }
    
    private func infoView(isImpersonating: Bool) -> some View {
                
        let title: String = isImpersonating
        ? "You are currently impersonating \(self.viewModel.userToImpersonateEmail)."
        : "Impersonate a user by using their email to receive a token from our auth service."
        
        let image: ImageSource = isImpersonating
        ? .systemImage("person.fill")
        : .systemImage("info.circle.fill")
        
        let gradient = LinearGradient(
            colors: [
                .indigo,
                .purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        let foregroundStyle: ColorSource = isImpersonating
        ? .linearGradient(gradient)
        : Style.shared.accent
        
        return InfoView(
            title: title,
            imageSource: image,
            foregroundStyle: foregroundStyle,
            action: nil
        )
        .contentTransition(.symbolEffect(.replace))
        .contentTransition(.numericText())
        .transition(.move(edge: .leading))
        
    }
    
    private func bottomButtonView(isImpersonating: Bool) -> some View {
        
        let title: String = isImpersonating ? "Revert" : "Impersonate"
        let isEnabled: Bool = isImpersonating ? true : self.viewModel.userToImpersonateEmail.count > 3
        
        return CommonButton(
            title: title,
            titleColor: Style.shared.textColor(.button),
            isEnabled: isEnabled
        ) {
            self.viewModel.impersonateOrRevert()
        }
        .contentTransition(.numericText())
        .animation(
            .bouncy(duration: 0.8),
            value: self.viewModel.isImpersonating
        )
        .padding(.horizontal, .extraLarge)
        
    }
    
}

#Preview {
    
    DevImpersonateScreen(
        viewModel: mockResolve(DevImpersonateViewModel.self)
    )
    .withMockServices()
    
}
