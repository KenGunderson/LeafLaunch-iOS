//
//  LoginScreen.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 5/16/25.
//


import SwiftUI
import AuthenticationServices

struct LoginScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case email
        case password
        
    }
    
    @StateObject var viewModel: LoginViewModel
    @Environment(NavigationService.self) private var navigationService
    @FocusState private var focusedField: FocusedField?
    
    @State private var showPassword: Bool = false
    
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            headerView
        } scrollViewContent: {
            contentView
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            bottomButton()
        }
        .onSubmit {
            handleOnSubmit()
        }
        
        .alertView(
            isPresented: self.$viewModel.shouldPresentForgotPassword,
            shouldDismissOnTouch: true,
            alertStyle: .forgotPassword(action: { email in
                self.viewModel.handleForgetPassword(email: email)
            })
        )
        
        .errorHandler(
            error: self.$viewModel.error,
            alertStyle: .simpleError(
                title: "Sign In Failed",
                message: (self.viewModel.error?.getMessageForError() ?? ""),
                action: {
                    self.viewModel.error = nil
                }
                
            )
        )
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }
        
    }
    
    private var headerView: some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            NavBarButton(style: .back) {
                self.navigationService.pop()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Welcome Back")
                    .appFont(with: .custom(.rounded(size: 32, weight: .bold)))
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Text("Sign in to your Grimoire account to continue capturing beautiful results")
                    .appFont(with: .BODY_3)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .medium)
        
    }
    
    private var contentView: some View {
        
        VStack(alignment: .trailing, spacing: Style.shared.spacing(.small)) {
            
            // Textfields
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                textField(fieldToFocus: .email)
                
                textField(
                    fieldToFocus: .password,
                    isSecureEntry: true
                )
                
            }
            
            // Forgot Password
            
            forgotPassword
            
        }
        
    }
    
    private var forgotPassword: some View {
        
        Text("Forgot Password?")
            .appFont(with: .TITLE_3)
            .foregroundStyle(Style.shared.accent.source())
            .asButton {
                self.viewModel.handleForgotPassword()
            }
        
    }
    
    private func bottomButton() -> some View {
        
        CommonButton(
            title: "Login",
            titleColor: Style.shared.textColor(.button),
            isEnabled: self.viewModel.isButtonEnabled,
            disabledOpacity: 0.75
        ) {
            self.viewModel.handleLogin()
        }
        .padding(.vertical, .small)
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func textField(fieldToFocus: FocusedField,
                           isSecureEntry: Bool = false) -> some View {
        
        let text = fieldToFocus == .email ? self.$viewModel.email : self.$viewModel.password
        let placeholder = fieldToFocus == .email ? "Email" : "Password"
        let isFocused = fieldToFocus == .email ? (focusedField == .email) : (focusedField == .password)
        
        Group {
            
            let hidePassword = !self.showPassword
            
            if isSecureEntry && hidePassword {
                
                SecureField(
                    placeholder,
                    text: text,
                    prompt: Text(placeholder).foregroundStyle(Style.shared.textColor(.placeholder).source())
                )

                
            } else {
                
                TextField(
                    placeholder,
                    text: text,
                    prompt: Text(placeholder).foregroundStyle(Style.shared.textColor(.placeholder).source())
                )
                
            }
            
        }
        .titleUnderlineTextFieldStyle(
            text: text.wrappedValue,
            title: placeholder,
            style: .border(cornerRadius: .custom(6)),
            isFocused: isFocused,
            textFieldFont: .BODY_3,
            titleFont: .BODY_2
        )
        .focused(self.$focusedField, equals: fieldToFocus)
        .keyboardType(fieldToFocus == .email ? .emailAddress : .default)
        .textContentType(fieldToFocus == .email ? .emailAddress : .password)
        .submitLabel(fieldToFocus == .password ? .done : .next)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .overlay(alignment: .bottomTrailing) {
            passwordEyeOverlay(isSecureEntry: isSecureEntry)
        }
        .appOnTapGesture {
            self.focusedField = fieldToFocus
        }
        
    }
    
    private func handleOnSubmit() {
        
        if self.focusedField == .email {
            self.focusedField = .password
        }
        else {
            self.focusedField = nil
        }
        
    }
    
    @ViewBuilder
    private func passwordEyeOverlay(isSecureEntry: Bool) -> some View {
        
        if isSecureEntry {
            
            Image(systemName: self.showPassword ? "eye.slash" : "eye")
                .scaledToFit()
                .frame(maxWidth: 24, maxHeight: 24)
                .asButton {
                    
                    withAnimation(.smooth) {
                        self.showPassword.toggle()
                    }
                    
                }
                .foregroundStyle(Style.shared.textColor(.body).source())
                .padding(.trailing, .medium)
                .padding(.bottom, .custom(10))
                .contentTransition(.symbolEffect(.replace))
            
        }
        
    }
    
}

#Preview {
    
    LoginScreen(
        viewModel: mockResolve(LoginViewModel.self)
    )
    .withMockServices()
    
}
