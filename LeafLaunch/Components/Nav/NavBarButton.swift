//
//  NavBarButton.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/30/26.
//

import SwiftUI

struct NavBarButton: View {

    private let style: Style
    private let foregroundColor: ColorSource
    private let action: () -> Void

    private let frame: CGFloat = 32

    init(style: Style,
         foregroundColor: ColorSource = .text(.title),
         action: @escaping () -> Void) {

        self.style = style
        self.foregroundColor = foregroundColor
        self.action = action

    }

    var body: some View {

        let notificationCount = self.style.notificationCount
        let notificationText = notificationCount > 99 ? "99+" : "\(notificationCount)"

        let imageFrame = self.frame * self.style.imageScale

        self.style.icon
            .view(renderingMode: .template)
            .scaledToFit()
            .frame(
                width: imageFrame,
                height: imageFrame
            )
            .foregroundStyle(self.foregroundColor)
            .frame(
                width: self.frame,
                height: self.frame
            )
            .background(.background(.secondary))
            .clipShape(.circle)
            .appBorder(cornerRadius: .extraLarge)
            .compositingGroup()
            .appShadow(.subtle)
            .asButton {
                self.action()
            }
            .commonBadge(
                contentStyle: .text(Text(notificationText)),
                placement: .init(
                    overlapStyle: .circular,
                    offset: CGSize(width: -2, height: 2),
                    anchorOutset: 4,
                    circularOverlapOutset: 0
                ),
                appearance: .init(
                    foregroundStyle: .text(.titleInverted),
                    backgroundStyle: .palette(.error),
                    borderStyle: .background(.primary),
                    borderLineWidth: 1
                ),
                sizing: .init(
                    textFont: .TITLE_2,
                    minWidth: 16,
                    minHeight: 16,
                    horizontalPadding: .extraSmall,
                    verticalPadding: .none
                ),
                behavior: .init(
                    isVisible: notificationCount > 0,
                    factorsIntoFrame: false
                )
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(self.style.accessibilityLabel)
            .accessibilityValue(self.style.accessibilityValue)

    }

}

#Preview {

    AppBaseView {

        VStack {

            NavBarButton(style: .back, action: {})
            NavBarButton(style: .close, action: {})
            NavBarButton(style: .settings, action: {})
            NavBarButton(style: .plus, action: {})
            NavBarButton(style: .filter(isFilled: true), action: {})
            NavBarButton(style: .filter(isFilled: false), action: {})
            NavBarButton(style: .bell(notificationCount: 6), action: {})
            NavBarButton(style: .bell(notificationCount: 65), action: {})

        }

    }

}
