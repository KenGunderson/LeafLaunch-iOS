//
//  LLTextFieldViewModifier.swift
//  LeafLaunch
//

import SwiftUI

private struct LLTextFieldViewModifier: ViewModifier {

    @Environment(\.style) private var style

    let title: String
    let icon: RNImageSource
    let isFocused: Bool

    func body(content: Content) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            Text(self.title)
                .runeFont(with: .BODY_2)
                .runeTextColor(.title)

            content
                .textFieldStyle(LLCommonTextFieldStyle(
                    icon: self.icon,
                    isFocused: self.isFocused
                ))

        }

    }

}

extension View {

    func llTextFieldStyle(title: String,
                          icon: RNImageSource,
                          isFocused: Bool) -> some View {

        modifier(LLTextFieldViewModifier(
            title: title,
            icon: icon,
            isFocused: isFocused
        ))

    }

}
