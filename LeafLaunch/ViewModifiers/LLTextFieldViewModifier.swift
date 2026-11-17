//
//  LLTextFieldViewModifier.swift
//  LeafLaunch
//

import SwiftUI

private struct LLTextFieldViewModifier: ViewModifier {

    @Environment(\.style) private var style

    let title: String
    let icon: ImageSource
    let isFocused: Bool

    func body(content: Content) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            Text(self.title)
                .appFont(with: .BODY_2)
                .foregroundStyle(.text(.title))

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
                          icon: ImageSource,
                          isFocused: Bool) -> some View {

        modifier(LLTextFieldViewModifier(
            title: title,
            icon: icon,
            isFocused: isFocused
        ))

    }

}
