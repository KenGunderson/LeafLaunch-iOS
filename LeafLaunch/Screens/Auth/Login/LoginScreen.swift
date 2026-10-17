//
//  LoginScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 5/16/25.
//


import SwiftUI
import AuthenticationServices

struct LoginScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: LoginViewModel
    @State private var showPassword: Bool = false

    @FocusState private var focusedField: FocusedField?

    enum FocusedField: Hashable {

        case email
        case password

    }

    init(viewModel: LoginViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    private func handleOnSubmit() {

        if self.focusedField == .email {
            self.focusedField = .password
        } else {
            self.focusedField = nil
        }

    }

    var body: some View {

        LLAppHeaderScrollView {
            headerView()
        } scrollViewContent: {
            contentView()
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

        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

    }

    @ViewBuilder
    private func headerView() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            NavBarButton(style: .back) {
                self.navigationService.pop()
            }

            VStack(alignment: .leading, spacing: 0) {

                Text("Welcome Back")
                    .appFont(with: .custom(.rounded(size: 32, weight: .bold)))
                    .foregroundStyle(.text(.title))

                Text("Sign in to your LeafLaunch account to continue capturing beautiful results")
                    .appFont(with: .BODY_3)
                    .foregroundStyle(.text(.body))

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .medium)

    }

    @ViewBuilder
    private func contentView() -> some View {

        VStack(alignment: .trailing, spacing: self.style.spacing(.small)) {

            // Textfields

            VStack(spacing: self.style.spacing(.medium)) {

                textField(fieldToFocus: .email)

                textField(
                    fieldToFocus: .password,
                    isSecureEntry: true
                )

            }

            // Forgot Password

            forgotPassword()

        }

    }

    @ViewBuilder
    private func forgotPassword() -> some View {

        Text("Forgot Password?")
            .appFont(with: .TITLE_3)
            .foregroundStyle(.foreground(.primary))
            .asButton {
                self.viewModel.handleForgotPassword()
            }

    }

    @ViewBuilder
    private func bottomButton() -> some View {

        CommonButton(
            title: "Login",
            titleColor: .text(.button),
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
        let isFocused = fieldToFocus == .email ? (self.focusedField == .email) : (self.focusedField == .password)

        Group {

            let hidePassword = !self.showPassword

            if isSecureEntry && hidePassword {

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
        .llTextFieldStyle(
            text: text.wrappedValue,
            title: placeholder,
            isFocused: isFocused
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

    @ViewBuilder
    private func passwordEyeOverlay(isSecureEntry: Bool) -> some View {

        if isSecureEntry {

            ImageSource.systemImage(self.showPassword ? "eye.slash" : "eye")
                .view(shouldResize: false)
                .scaledToFit()
                .frame(maxWidth: 24, maxHeight: 24)
                .asButton {

                    withAnimation(.smooth) {
                        self.showPassword.toggle()
                    }

                }
                .foregroundStyle(.text(.body))
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
