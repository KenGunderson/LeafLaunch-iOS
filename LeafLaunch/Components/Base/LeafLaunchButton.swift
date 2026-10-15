//
//  LeafLaunchButton.swift
//  LeafLaunch
//

import SwiftUI

struct LeafLaunchButton: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String
    private let icon: ImageSource?
    private let action: () -> Void

    init(
        title: String,
        icon: ImageSource? = nil,
        action: @escaping () -> Void
    ) {

        self.title = title
        self.icon = icon
        self.action = action

    }

    var body: some View {

        CommonButton(
            title: self.title,
            icon: self.icon,
            cornerRadius: .medium,
            buttonBounceStyle: self.reduceMotion ? .init(scale: 1, opacity: 1, brightness: 0) : self.style.buttonBounceStyle,
            action: self.action
        )

    }

}
