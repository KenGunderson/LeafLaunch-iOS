//
//  GrimoireButton.swift
//  Grimoire
//

import SwiftUI

struct GrimoireButton: View {

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
            cornerRadius: .custom(999),
            action: self.action
        )

    }

}
