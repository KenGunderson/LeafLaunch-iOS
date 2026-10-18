//
//  LeafLaunchButton.swift
//  LeafLaunch
//

import SwiftUI

struct LeafLaunchButton: View {

    private let title: String
    private let icon: ImageSource?
    private let iconAlignment: HorizontalAlignment
    private let isEnabled: Bool
    private let action: () -> Void

    init(title: String,
         icon: ImageSource? = nil,
         iconAlignment: HorizontalAlignment = .leading,
         isEnabled: Bool = true,
         action: @escaping () -> Void) {

        self.title = title
        self.icon = icon
        self.iconAlignment = iconAlignment
        self.isEnabled = isEnabled
        self.action = action

    }

    var body: some View {

        CommonButton(
            title: self.title,
            icon: self.icon,
            iconAlignment: self.iconAlignment,
            isEnabled: self.isEnabled,
            cornerRadius: .medium,
            action: self.action
        )

    }

}
