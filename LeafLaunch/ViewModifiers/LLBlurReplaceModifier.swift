//
//  LLBlurReplaceModifier.swift
//  LeafLaunch
//

import SwiftUI

private struct LLBlurReplaceModifier<Value: Hashable>: ViewModifier {

    let value: Value
    let transition: AnyTransition
    let animation: Animation?

    func body(content: Content) -> some View {

        content
            .id(self.value)
            .transition(self.transition)
            .animation(
                self.animation,
                value: self.value
            )

    }

}

extension View {

    func llBlurReplace<Value: Hashable>(value: Value,
                                        transition: AnyTransition = .init(.blurReplace),
                                        animation: Animation? = .smooth) -> some View {

        modifier(LLBlurReplaceModifier(
            value: value,
            transition: transition,
            animation: animation
        ))

    }

}
