//
//  LeafLaunchButton.swift
//  LeafLaunch
//

import SwiftUI

struct LeafLaunchButton: View {

    private let title: String
    private let icon: ImageSource?
    private let action: () -> Void

    init(title: String,
         icon: ImageSource? = nil,
         action: @escaping () -> Void) {

        self.title = title
        self.icon = icon
        self.action = action

    }

    var body: some View {

        CommonButton(
            title: self.title,
            icon: self.icon,
            cornerRadius: .medium,
            action: self.action
        )

    }

}
