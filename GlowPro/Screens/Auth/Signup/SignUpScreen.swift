//
//  SignUpScreen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI
import AuthenticationServices

struct SignUpScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case firstName
        case lastName
        case email
        case password
        
    }
    
    @StateObject var viewModel: SignUpViewModel
    @Environment(NavigationService.self) private var navigationService

    @State private var showPassword: Bool = false
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            headerView
        } scrollViewContent: {
            contentView
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
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
        
        // Sheets
        
        .adaptiveSheet(
            isPresented: self.$viewModel.showEmailVerificationSheet,
            backgroundStyle: Style.shared.background(.primary)
        ) {
            
            EmailVerificationSheet(email: self.viewModel.email) {
                
                self.viewModel
                    .handleSignUp()
                
            }
            
        }
        
        // Tap
    
        .onSubmit {
            handleOnSubmit()
        }
        
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
                
                Text("Join GlowPro")
                    .appFont(with: .custom(.rounded(size: 32, weight: .bold)))
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Text("Enter your details below to create an account.")
                    .appFont(with: .BODY_3)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .medium)
        
    }
    
    private var contentView: some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            // TextFields
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                textField(fieldToFocus: .firstName)
                textField(fieldToFocus: .lastName)
                textField(fieldToFocus: .email)
                textField(fieldToFocus: .password)
                
            }
            
        }
        
    }
    
    private func bottomBar() -> some View {
        
        VStack(alignment: .leading) {
            
            HStack(spacing: Style.shared.spacing(.none)) {
                
                // Checkbox
                
                Toggle(
                    "",
                    isOn: self.$viewModel.agreedToTerms
                )
                .toggleStyle(.checkmark(
                    height: 28,
                    unselectedColor: Style.shared.background(.quaternary),
                    horizontalSpacing: .small,
                    cornerRadius: .extraSmall
                ))
                .contentTransition(.symbolEffect(.replace))
                .foregroundStyle(Style.shared.textColor(.body).source())
                .appFont(with: .BODY_2)
                .animation(.bouncy, value: self.viewModel.agreedToTerms)
                
                // Attributed Text
                
                AttributedText {
                    
                    Text("By signing up, you agree to our ")
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .font(Style.shared.font(.BODY_2))
                    
                    Text("[Terms Of Service](https://apple.com)")
                        .font(Style.shared.font(.BODY_2))
                        .foregroundStyle(Style.shared.accent.source())
                        .underline()
                    
                }
                .environment(\.openURL, .init(handler: { url in
                    
                    self.navigationService
                        .push(.setting(.termsOfService))
                    
                    return .handled
                    
                }))
                .tint(Style.shared.accent.source())
                
            }
                        
            // LoginButton
            
            CommonButton(
                title: "Create Account",
                titleColor: Style.shared.textColor(.button),
                isEnabled: self.viewModel.isButtonEnabled) {
                
                    self.viewModel
                        .confirmEmail()
                    
                }
                .padding(.vertical, .small)
            
        }
        .background(Style.shared.background(.primary).source())
        .padding(.horizontal, .medium)
        .opacity(self.focusedField == nil ? 1 : 0)
        
    }

    private func textField(fieldToFocus: FocusedField) -> some View {
        
        var text: Binding<String> = .constant("")
        var placeholder: String = ""
        var isFocused: Bool = false
        var keyboardType: UIKeyboardType = .default
        var textContentType: UITextContentType = .emailAddress
        var submitLabel: SubmitLabel = .next
        
        let isNameFields: Bool = (fieldToFocus == .firstName) || (fieldToFocus == .lastName)
        
        switch fieldToFocus {
        case .firstName:

            text = self.$viewModel.firstName
            placeholder = "First Name"
            isFocused = self.focusedField == .firstName
            keyboardType = .default
            textContentType = .name
            submitLabel = .next
            
        case .lastName:

            text = self.$viewModel.lastName
            placeholder = "Last Name"
            isFocused = self.focusedField == .lastName
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
        .keyboardType(keyboardType)
        .textContentType(textContentType)
        .submitLabel(submitLabel)
        .textInputAutocapitalization(isNameFields ? .words : .never)
        .overlay(alignment: .bottomTrailing) {
            passwordEyeOverlay(fieldToFocus: fieldToFocus)
        }
        .appOnTapGesture {
            self.focusedField = fieldToFocus // We do this to increate tappable area
        }
        
    }
    
    private func handleOnSubmit() {
        
        switch self.focusedField {
        case .firstName: return self.focusedField = .lastName
        case .lastName: return self.focusedField = .email
        case .email: return self.focusedField = .password
        case .password: return self.focusedField = nil
        default: return self.focusedField = nil
        }
        
    }
    
    @ViewBuilder
    private func passwordEyeOverlay(fieldToFocus: FocusedField) -> some View {
        
        if fieldToFocus == .password {
            
            Image(systemName: self.showPassword ? "eye.slash" : "eye")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Style.shared.textColor(.placeholder).source())
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
    
    SignUpScreen(
        viewModel: mockResolve(SignUpViewModel.self)
    )
    .withMockServices()
    
}
