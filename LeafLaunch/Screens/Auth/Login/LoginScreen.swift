//
//  LoginScreen.swift
//  LeafLaunch
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

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: LoginViewModel
    @State private var showPassword: Bool = false

    @FocusState private var focusedField: FocusedField?

    init(viewModel: LoginViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        LLAppHeaderScrollView {
            headerView()
        } scrollViewContent: {
            contentView()
        }
        .scrollBounceBehavior(.basedOnSize)
        .onSubmit {
            handleOnSubmit()
        }

        .runeAlertView(
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

    private func handleOnSubmit() {

        if self.focusedField == .email {
            self.focusedField = .password
        } else {
            self.focusedField = nil
        }

    }

    @ContentBuilder
    private func headerView() -> some View {

        NavHeader(
            title: String(localized: "Welcome Back"),
            subtitle: String(localized: "Sign in to your LeafLaunch account to continue capturing beautiful results"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { _ in self.navigationService.pop() }
        )

    }

    @ContentBuilder
    private func contentView() -> some View {

        VStack(
            alignment: .trailing,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            fields()
            forgotPassword()
            loginAction()

        }
        .runePadding(.bottom, LLSpacing.listRow)

    }

    @ContentBuilder
    private func fields() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.listRow)) {

            textField(fieldToFocus: .email)

            textField(
                fieldToFocus: .password,
                isSecureEntry: true
            )

        }

    }

    @ContentBuilder
    private func forgotPassword() -> some View {

        Text("Forgot Password?")
            .runeFont(with: .TITLE_3)
            .runeForeground(.primary)
            .runeAsButton {
                self.viewModel.handleForgotPassword()
            }

    }

    @ContentBuilder
    private func loginAction() -> some View {

        LeafLaunchButton(
            title: "Login",
            isEnabled: self.viewModel.isButtonEnabled,
            cornerRadius: .medium2,
            disabledOpacity: 0.75
        ) {
            self.viewModel.handleLogin()
        }
        .runePadding(.vertical, LLSpacing.groupedContent)

    }

    @ContentBuilder
    private func textField(fieldToFocus: FocusedField,
                           isSecureEntry: Bool = false) -> some View {

        let text = fieldToFocus == .email ? self.$viewModel.email : self.$viewModel.password
        let title = fieldToFocus == .email ? "Email" : "Password"
        let placeholder = fieldToFocus == .email ? "jamie@example.com" : "e.g. CedarLeaf42!"
        let icon: RNImageSource = .systemImage(fieldToFocus == .email ? "envelope" : "lock")
        let isFocused = fieldToFocus == .email ? (self.focusedField == .email) : (self.focusedField == .password)

        Group {

            let hidePassword = !self.showPassword

            if isSecureEntry && hidePassword {

                SecureField(
                    title,
                    text: text,
                    prompt: Text(placeholder).runeTextColor(.placeholder)
                )

            } else {

                TextField(
                    title,
                    text: text,
                    prompt: Text(placeholder).runeTextColor(.placeholder)
                )

            }

        }
        .focused(
            self.$focusedField,
            equals: fieldToFocus
        )
        .llTextFieldStyle(
            title: title,
            icon: icon,
            isFocused: isFocused
        )
        .keyboardType(fieldToFocus == .email ? .emailAddress : .default)
        .textContentType(fieldToFocus == .email ? .emailAddress : .password)
        .submitLabel(fieldToFocus == .password ? .done : .next)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .overlay(alignment: .bottomTrailing) {
            passwordEyeOverlay(isSecureEntry: isSecureEntry)
        }
        .runeOnTapGesture(isSimultaneous: true) {
            self.focusedField = fieldToFocus
        }

    }

    @ContentBuilder
    private func passwordEyeOverlay(isSecureEntry: Bool) -> some View {

        if isSecureEntry {

            RNImageSource.systemImage(self.showPassword ? "eye.slash" : "eye")
                .view(shouldResize: false)
                .scaledToFit()
                .frame(maxWidth: 24, maxHeight: 24)
                .runeAsButton {

                    withAnimation(.smooth) {
                        self.showPassword.toggle()
                    }

                }
                .runeTextColor(.placeholder)
                .runePadding(.trailing, LLSpacing.pageInset)
                .runePadding(.bottom, LLSpacing.cardContent)
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
