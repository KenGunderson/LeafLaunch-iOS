//
//  LLCommonTextFieldStyle.swift
//  LeafLaunch
//

import SwiftUI

@MainActor
struct LLCommonTextFieldStyle: TextFieldStyle {

    @Environment(\.style) private var style

    private let icon: ImageSource
    private let isFocused: Bool

    init(icon: ImageSource, isFocused: Bool) {
        self.icon = icon
        self.isFocused = isFocused
    }

    func _body(configuration: TextField<Self._Label>) -> some View {

        HStack(spacing: self.style.spacing(.small2)) {

            leadingIcon()
            configuration

        }
        .frame(height: 48)
        .padding(.horizontal, .medium)
        .appFont(with: .BODY_3)
        .foregroundStyle(self.style.textColor(.title))
        .background(self.style.background(.secondary))
        .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium2)))
        .appBorder(
            cornerRadius: .medium2,
            color: .background(.border),
            lineWidth: 0.8,
            outerBorder: false
        )
        .tint(self.style.foreground(.primary))

    }

    @ViewBuilder
    private func leadingIcon() -> some View {

        self.icon.view()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18)
            .foregroundStyle(self.isFocused ? self.style.foreground(.primary) : self.style.textColor(.placeholder))
            .accessibilityHidden(true)

    }

}

#Preview {

    @Previewable @State var email = ""
    @Previewable @State var password = ""

    AppBaseView {

        VStack(spacing: 16) {

            TextField(
                "Email",
                text: $email,
                prompt: Text("jamie@example.com").foregroundStyle(.text(.placeholder))
            )
            .textFieldStyle(LLCommonTextFieldStyle(icon: .systemImage("envelope"), isFocused: false))

            SecureField(
                "Password",
                text: $password,
                prompt: Text("e.g. CedarLeaf42!").foregroundStyle(.text(.placeholder))
            )
            .textFieldStyle(LLCommonTextFieldStyle(icon: .systemImage("lock"), isFocused: true))

        }
        .padding(.medium)

    }
    .withMockPreviews()

}
