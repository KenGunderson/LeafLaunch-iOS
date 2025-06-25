//
//  LoginScreen.swift
//  GlowPro 
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
        
        AppHeaderScrollView {
            
            navBarView
            
        } scrollViewContent: {
            
            contentView
            
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            forgotPasswordButton
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
    
    private var navBarView: some View {
        
        let backButton = BackButton {
            self.viewModel.dismiss()
        }
        
       return NavBarView(
            title: "Login to your account",
            subtitle: "Enter your credentials below",
            leftButtonView: backButton.asAnyView()
        )
        
    }
    
    private var contentView: some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            // Textfields
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                textField(fieldToFocus: .email)
                
                textField(
                    fieldToFocus: .password,
                    isSecureEntry: true
                )
                
            }
            
            // LoginButton
            
            CommonButton(
                title: "Login",
                titleColor: Style.shared.textColor(.button),
                isEnabled: self.viewModel.isButtonEnabled) {
                    self.viewModel.handleLogin()
                }
                .padding(.top, .small)
            
        }
        
    }
    
    private var forgotPassword: some View {
        
        Text("Forgot your password?") {
            
            $0.font = Style.shared.font(.BODY_B5)
            $0.foregroundColor = Style.shared.textColor(.title).asColor
            
        }
        
        +
        
        Text(" Click here")  {
            
            $0.font = Style.shared.font(.TITLE_T5)
            $0.foregroundColor = Style.shared.accent.asColor
            
        }
        
    }
    
    private var forgotPasswordButton: some View {
        
        Button(action: {
            self.viewModel.handleForgotPassword()
        }, label: {
            forgotPassword
        })
        .customSafeAreaPadding()
        
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
                    prompt: Text(placeholder).foregroundStyle(Style.shared.textColor(.body).source())
                )

                
            } else {
                
                TextField(
                    placeholder,
                    text: text,
                    prompt: Text(placeholder).foregroundStyle(Style.shared.textColor(.body).source())
                )
                
            }
            
        }
        .titleUnderlineTextFieldStyle(
            text: text.wrappedValue,
            title: placeholder,
            style: .border(cornerRadius: .custom(6)),
            isFocused: isFocused
        )
        .focused(self.$focusedField, equals: fieldToFocus)
        .keyboardType(fieldToFocus == .email ? .emailAddress : .default)
        .textContentType(fieldToFocus == .email ? .emailAddress : .password)
        .submitLabel(fieldToFocus == .email ? .next : .done)
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
                .resizable()
                .scaledToFit()
                .foregroundStyle(Style.shared.textColor(.body).source())
                .frame(width: 24, height: 24)
                .asButton {
                    withAnimation(.spring) {
                        self.showPassword.toggle()
                    }
                }
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
