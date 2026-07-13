//
//  SignUpScreen.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI
import AuthenticationServices

struct SignUpScreen: GPView {

    @Environment(\.style) private var style
    
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
        
        // Tap
    
        .onSubmit {
            handleOnSubmit()
        }
        
        .onFirstAppear { [weak viewModel] in
            
            viewModel?
                .handleFirstAppear()
            
            viewModel?
                .setup(navigationService: self.navigationService)
            
        }
        
    }
    
    private var headerView: some View {
        
        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {
            
            NavBarButton(style: .back) {
                self.navigationService.pop()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Join Grimoire")
                    .appFont(with: .custom(.rounded(size: 32, weight: .bold)))
                    .foregroundStyle(.text(.title))
                
                Text("Enter your details below to create an account.")
                    .appFont(with: .BODY_3)
                    .foregroundStyle(.text(.body))
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .medium)
        
    }
    
    private var contentView: some View {
        
        VStack(spacing: self.style.spacing(.medium)) {
            
            // TextFields
            
            VStack(spacing: self.style.spacing(.medium)) {
                
                textField(fieldToFocus: .firstName)
                textField(fieldToFocus: .lastName)
                textField(fieldToFocus: .email)
                textField(fieldToFocus: .password)
                
            }
            
        }
        
    }
    
    private func bottomBar() -> some View {
        
        VStack(alignment: .leading) {
            
            HStack(spacing: self.style.spacing(.none)) {
                
                // Checkbox
                
                Toggle(
                    "",
                    isOn: self.$viewModel.agreedToTerms
                )
                .toggleStyle(.checkmarkFilled(
                    height: 30,
                    unselectedColor: .background(.quaternary),
                    horizontalSpacing: .small,
                    cornerRadius: .extraSmall,
                    animation: .bouncy(duration: 0.3, extraBounce: 0.2)
                ))
                .foregroundStyle(.text(.titleInverted))
                .appFont(with: .TITLE_5)
                .contentTransition(.symbolEffect(.replace))
//                .animation(.bouncy(duration: 0.10), value: self.viewModel.agreedToTerms)
                
                // Attributed Text
                
                AttributedText {
                    
                    Text("By signing up, you agree to our ")
                        .foregroundStyle(.text(.body))
                        .font(self.style.font(.BODY_2))
                    
                    Text("[Terms Of Service](https://apple.com)")
                        .font(self.style.font(.BODY_2))
                        .foregroundStyle(.foreground(.primary))
                        .underline()
                    
                }
                .environment(\.openURL, .init(handler: { url in
                    
//                    self.navigationService
//                        .push(.setting(.termsOfService))
                    
                    return .handled
                    
                }))
                .tint(.init(.foreground(.primary)))
                
            }
                        
            // LoginButton
            
            CommonButton(
                title: "Create Account",
                titleColor: .text(.button),
                isEnabled: self.viewModel.isButtonEnabled,
                disabledOpacity: 0.7
            ) {
                
                self.viewModel
                    .handleSignUp()
                
            }
            .padding(.vertical, .small)
            
        }
        .background(.background(.primary))
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
                    prompt: Text(placeholder).foregroundStyle(.text(.placeholder))
                )
                
            } else {
                
                TextField(
                    placeholder,
                    text: text,
                    prompt: Text(placeholder).foregroundStyle(.text(.placeholder))
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
        .disableAutocorrection(true)
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
                .foregroundStyle(.text(.placeholder))
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
