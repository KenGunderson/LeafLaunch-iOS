//
//  SignUpScreen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI
import AuthenticationServices

struct SignUpScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case name
        case email
        case password
        
    }
    
    @StateObject var viewModel: SignUpViewModel
    @Environment(NavigationService.self) private var navigationService

    @State private var showPassword: Bool = false
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        
        AppHeaderScrollView {
            
            navBarView
            
        } scrollViewContent: {
            
            contentView
            
        }
        .scrollBounceBehavior(.basedOnSize)
        .errorHandler(
            error: self.$viewModel.error,
            alertStyle: .simpleError(
                
                message: (self.viewModel.error?.getMessageForError() ?? ""),
                action: {
                    self.viewModel.error = nil
                }
                
        ))
        
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
            title: "Create Your Account",
            subtitle: "Enter your credentials below",
            leftButtonView: backButton.asAnyView()
        )
        
    }
    
    private var contentView: some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            // TextFields
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                textField(fieldToFocus: .name)
                textField(fieldToFocus: .email)
                textField(fieldToFocus: .password)
                
            }
            
            // LoginButton
            
            CommonButton(
                title: "Create Account",
                isEnabled: self.viewModel.isButtonEnabled) {
                    self.viewModel.handleSignUp()
                }
                .padding(.top, .small)
            
            // Divider View
            
            dividerView
            
            // Apple Button
            
            appleButton
            
        }
        
    }
    
    private var dividerView: some View {
        
        HStack {
            
            Capsule()
                .stroke(.gray.opacity(0.3))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            Text("or")
            
            Capsule()
                .stroke(.gray.opacity(0.3))
                .frame(height: 1)
                .frame(maxWidth: .infinity)

        }
        .foregroundStyle(Style.shared.textColor(.body).source())
        
    }
    
    private var appleButton: some View {
        
        SignInWithAppleButton(.signUp) { request in
            
            let nonce = randomNonceString()
            self.viewModel.set(nonce: nonce)
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
        } onCompletion: { result in
            self.viewModel.handleAppleAuthoriziation(result: result)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: Style.shared.radius(.small2)))
        .ignoresSafeArea(.keyboard)
        
    }
    
    private func textField(fieldToFocus: FocusedField) -> some View {
        
        var text: Binding<String> = .constant("")
        var placeholder: String = ""
        var isFocused: Bool = false
        var keyboardType: UIKeyboardType = .default
        var textContentType: UITextContentType = .emailAddress
        var submitLabel: SubmitLabel = .next
        
        switch fieldToFocus {
        case .name:

            text = self.$viewModel.name
            placeholder = "Name"
            isFocused = self.focusedField == .name
            keyboardType = .default
            textContentType = .name
            submitLabel = .next
            
        case .email:
            
            text = self.$viewModel.email
            placeholder = "Email"
            isFocused = self.focusedField == .email
            keyboardType = .emailAddress
            textContentType = .emailAddress
            submitLabel = .next
            
        case .password:
            
            text = self.$viewModel.password
            placeholder = "Password"
            isFocused = self.focusedField == .password
            keyboardType = .default
            textContentType = .password
            submitLabel = .next
        }
        
        return Group {
            
            let hidePassword = !self.showPassword
            
            if fieldToFocus == .password && hidePassword {
                
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
        .appTextFieldStyle(
            text: text.wrappedValue,
            hint: placeholder,
            isFocused: isFocused
        )
        .focused(self.$focusedField, equals: fieldToFocus)
        .keyboardType(keyboardType)
        .textContentType(textContentType)
        .submitLabel(submitLabel)
        .textInputAutocapitalization(fieldToFocus == .name ? .words : .never)
        .overlay(alignment: .trailing) {
            
            if fieldToFocus == .password {
                
                Image(systemName: self.showPassword ? "eye.slash" : "eye")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .frame(width: 24, height: 24)
                    .asButton {
                        self.showPassword.toggle()
                    }
                    .padding(.trailing, .medium)
                
            }
            
        }
        .appOnTapGesture {
            self.focusedField = fieldToFocus // We do this to increate tappable area
        }
        
    }
    
    private func handleOnSubmit() {
        
        switch self.focusedField {
        case .name: return self.focusedField = .email
        case .email: return self.focusedField = .password
        case .password: return self.focusedField = nil
        default: return self.focusedField = nil
        }
        
    }
    
}

#Preview {
    
    SignUpScreen(
        viewModel: mockResolve(SignUpViewModel.self)
    )
    .withMockServices()
    
}
