//
//  SignUpScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 5/16/25.
//

import SwiftUI
import AuthenticationServices

struct SignUpScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: SignUpViewModel
    @State private var showPassword: Bool = false

    @FocusState private var focusedField: FocusedField?

    enum FocusedField: Hashable {

        case firstName
        case lastName
        case email
        case password

    }

    init(viewModel: SignUpViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    private func handleOnSubmit() {

        switch self.focusedField {
        case .firstName: self.focusedField = .lastName
        case .lastName: self.focusedField = .email
        case .email: self.focusedField = .password
        case .password: self.focusedField = nil
        default: self.focusedField = nil
        }

    }

    var body: some View {

        LLAppHeaderScrollView {
            headerView()
        } scrollViewContent: {
            contentView()
        }
        .scrollBounceBehavior(.basedOnSize)
        // Tap

        .onSubmit {
            handleOnSubmit()
        }

        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

    }

    @ViewBuilder
    private func headerView() -> some View {

        NavHeader(
            title: String(localized: "Join LeafLaunch"),
            subtitle: String(localized: "Enter your details below to create an account."),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { _ in self.navigationService.pop() }
        )

    }

    @ViewBuilder
    private func contentView() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            fields()
            signUpActions()

        }
        .padding(.bottom, .medium)

    }

    @ViewBuilder
    private func signUpActions() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            termsAgreement()
            signUpAction()

        }

    }

    @ViewBuilder
    private func fields() -> some View {

        VStack(spacing: self.style.spacing(.medium)) {

            textField(fieldToFocus: .firstName)
            textField(fieldToFocus: .lastName)
            textField(fieldToFocus: .email)
            textField(fieldToFocus: .password)

        }

    }

    @ViewBuilder
    private func termsAgreement() -> some View {

        Toggle(isOn: self.$viewModel.agreedToTerms) {
            termsCopy()
        }
        .toggleStyle(.checkmarkFilled(
            height: 20,
            textColor: .text(.body),
            unselectedColor: .background(.quaternary),
            horizontalSpacing: .small,
            cornerRadius: .extraSmall,
            animation: .bouncy(duration: 0.3, extraBounce: 0.2)
        ))
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(String(localized: "Agree To Terms Of Service"))

    }

    @ViewBuilder
    private func termsCopy() -> some View {

        AttributedText {

            Text("By signing up, you agree to our ")
                .foregroundStyle(.text(.body))
                .font(self.style.font(.NOTE_2))

            Text("[Terms Of Service](https://apple.com)")
                .font(self.style.font(.NOTE_2))
                .foregroundStyle(.foreground(.primary))
                .underline()

        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .environment(\.openURL, .init(handler: { _ in .handled }))
        .tint(.init(.foreground(.primary)))

    }

    @ViewBuilder
    private func signUpAction() -> some View {

        LeafLaunchButton(
            title: "Create Account",
            isEnabled: self.viewModel.isButtonEnabled,
            cornerRadius: .medium2,
            disabledOpacity: 0.7
        ) {

            self.viewModel
                .handleSignUp()

        }

    }

    private func textField(fieldToFocus: FocusedField) -> some View {

        var text: Binding<String> = .constant("")
        var title: String = ""
        var placeholder: String = ""
        var icon: ImageSource = .systemImage("person")
        var isFocused: Bool = false
        var keyboardType: UIKeyboardType = .default
        var textContentType: UITextContentType = .emailAddress
        var submitLabel: SubmitLabel = .next

        let isNameFields: Bool = (fieldToFocus == .firstName) || (fieldToFocus == .lastName)

        switch fieldToFocus {
        case .firstName:

            text = self.$viewModel.firstName
            title = "First Name"
            placeholder = "e.g. Jamie"
            isFocused = self.focusedField == .firstName
            keyboardType = .default
            textContentType = .name
            submitLabel = .next

        case .lastName:

            text = self.$viewModel.lastName
            title = "Last Name"
            placeholder = "e.g. Taylor"
            isFocused = self.focusedField == .lastName
            keyboardType = .default
            textContentType = .name
            submitLabel = .next

        case .email:

            text = self.$viewModel.email
            title = "Email"
            placeholder = "jamie@example.com"
            icon = .systemImage("envelope")
            isFocused = self.focusedField == .email
            keyboardType = .emailAddress
            textContentType = .emailAddress
            submitLabel = .next

        case .password:

            text = self.$viewModel.password
            title = "Password"
            placeholder = "e.g. CedarLeaf42!"
            icon = .systemImage("lock")
            isFocused = self.focusedField == .password
            keyboardType = .default
            textContentType = .password
            submitLabel = .next
        }

        return Group {

            let hidePassword = !self.showPassword

            if fieldToFocus == .password && hidePassword {

                SecureField(
                    title,
                    text: text,
                    prompt: Text(placeholder).foregroundStyle(.text(.placeholder))
                )

            } else {

                TextField(
                    title,
                    text: text,
                    prompt: Text(placeholder).foregroundStyle(.text(.placeholder))
                )

            }

        }
        .focused(self.$focusedField, equals: fieldToFocus)
        .llTextFieldStyle(
            title: title,
            icon: icon,
            isFocused: isFocused
        )
        .keyboardType(keyboardType)
        .textContentType(textContentType)
        .submitLabel(submitLabel)
        .textInputAutocapitalization(isNameFields ? .words : .never)
        .disableAutocorrection(true)
        .overlay(alignment: .bottomTrailing) {
            passwordEyeOverlay(fieldToFocus: fieldToFocus)
        }
        .appOnTapGesture(isSimultaneous: true) {
            self.focusedField = fieldToFocus
        }

    }

    @ViewBuilder
    private func passwordEyeOverlay(fieldToFocus: FocusedField) -> some View {

        if fieldToFocus == .password {

            ImageSource.systemImage(self.showPassword ? "eye.slash" : "eye")
                .view()
                .scaledToFit()
                .foregroundStyle(.text(.placeholder))
                .frame(width: 24, height: 24)
                .asButton {

                    withAnimation(.spring) {
                        self.showPassword.toggle()
                    }

                }
                .padding(.trailing, .medium)
                .padding(.bottom, .small2)
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
