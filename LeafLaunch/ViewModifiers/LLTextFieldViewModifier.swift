//
//  LLTextFieldViewModifier.swift
//  LeafLaunch
//

import SwiftUI

private struct LLTextFieldViewModifier: ViewModifier {

    let text: String
    let title: String
    let isFocused: Bool

    func body(content: Content) -> some View {

        content
            .titleUnderlineTextFieldStyle(
                text: self.text,
                title: self.title,
                style: .border(cornerRadius: .medium2),
                isFocused: self.isFocused,
                textFieldFont: .BODY_3,
                titleFont: .BODY_2
            )

    }

}

extension View {

    func llTextFieldStyle(text: String,
                          title: String,
                          isFocused: Bool) -> some View {

        modifier(LLTextFieldViewModifier(
            text: text,
            title: title,
            isFocused: isFocused
        ))

    }

}
