//
//  LLCommonTextFieldStyle.swift
//  LeafLaunch
//

import SwiftUI

@MainActor
struct LLCommonTextFieldStyle: TextFieldStyle {

    @Environment(\.style) private var style

    private let icon: RNImageSource
    private let isFocused: Bool

    init(icon: RNImageSource, isFocused: Bool) {

        self.icon = icon
        self.isFocused = isFocused

    }

    func _body(configuration: TextField<Self._Label>) -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.section)) {

            leadingIcon()
            configuration

        }
        .frame(height: 48)
        .runePadding(.horizontal, LLSpacing.pageInset)
        .runeFont(with: .BODY_3)
        .runeTextColor(.title)
        .runeBackground(.secondary)
        .runeCornerRadius(.medium2)
        .runeBorder(
            cornerRadius: .medium2,
            color: self.isFocused ? .foreground(.primary) : .background(.border),
            lineWidth: 0.8,
            outerBorder: false
        )
        .runeTint(.primary)

    }

    @ContentBuilder
    private func leadingIcon() -> some View {

        self.icon.view()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: 18,
                height: 18
            )
            .foregroundStyle(self.isFocused ? RNColorSource.foreground(.primary) : .text(.placeholder))
            .accessibilityHidden(true)

    }

}

#Preview {

    @Previewable @Environment(\.style) var style

    @Previewable @State var email = ""
    @Previewable @State var password = ""

    RNBaseView {

        VStack(spacing: style.spacing(LLSpacing.listRow)) {

            TextField(
                "Email",
                text: $email,
                prompt: Text("jamie@example.com").runeTextColor(.placeholder)
            )
            .textFieldStyle(LLCommonTextFieldStyle(
                icon: .systemImage("envelope"),
                isFocused: false
            ))

            SecureField(
                "Password",
                text: $password,
                prompt: Text("e.g. CedarLeaf42!").runeTextColor(.placeholder)
            )
            .textFieldStyle(LLCommonTextFieldStyle(
                icon: .systemImage("lock"),
                isFocused: true
            ))

        }
        .runePadding(LLSpacing.pageInset)

    }
    .withMockPreviews()

}
