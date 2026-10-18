//
//  LeafLaunchButton.swift
//  LeafLaunch
//

import SwiftUI

struct LeafLaunchButton: View {

    @Environment(\.style) private var style

    private let title: String
    private let icon: ImageSource?
    private let iconAlignment: HorizontalAlignment
    private let size: LeafLaunchButtonSize
    private let isEnabled: Bool
    private let action: () -> Void

    init(title: String,
         icon: ImageSource? = nil,
         iconAlignment: HorizontalAlignment = .leading,
         size: LeafLaunchButtonSize = .standard,
         isEnabled: Bool = true,
         action: @escaping () -> Void) {

        self.title = title
        self.icon = icon
        self.iconAlignment = iconAlignment
        self.size = size
        self.isEnabled = isEnabled
        self.action = action

    }

    var body: some View {

        if self.size == .prominent {

            prominentButton()

        } else {

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

    @ViewBuilder
    private func prominentButton() -> some View {

        Button {

            self.action()
            Haptics.shared.vibrate(option: .selection)

        } label: {

            HStack(spacing: self.style.spacing(.small)) {

                if let icon = self.icon {

                    icon.view(shouldResize: false)
                        .opacity(self.iconAlignment == .leading ? 1 : 0)

                }

                Text(self.title)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                if let icon = self.icon {

                    icon.view(shouldResize: false)
                        .opacity(self.iconAlignment == .trailing ? 1 : 0)

                }

            }
            .appFont(with: .TITLE_4)
            .foregroundStyle(.text(.button))

        }
        .buttonStyle(.commonButtonStyle(
            background: .foreground(.primary),
            cornerRadius: .medium2,
            isEnabled: self.isEnabled,
            verticalPadding: .small2,
            horizontalPadding: .large
        ))
        .disabled(!self.isEnabled)
        .opacity(self.isEnabled ? 1 : 0.8)

    }

}
