//
//  TabFlowContentSpacingModifier.swift
//  JobLens
//

import SwiftUI

private struct TabFlowContentSpacingModifier: ViewModifier {

    func body(content: Content) -> some View {

        content
            .padding(.bottom, .custom(120))

    }

}

extension View {

    func tabFlowContentSpacing() -> some View {
        return modifier(TabFlowContentSpacingModifier())
    }

}
