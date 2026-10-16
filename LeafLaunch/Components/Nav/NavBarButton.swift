//
//  NavBarButton.swift
//  JobLens
//
//  Created by Sako Hovaguimian on 7/30/26.
//

import SwiftUI

struct NavBarButton: View {

    enum Style: Hashable {

        case back
        case close
        case settings
        case ellipsis
        case plus
        case bell(notificationCount: Int = 0)
        case pencil
        case filter(isFilled: Bool = false)
        case trash
        case star(isFilled: Bool = false)

        var icon: ImageSource {

            switch self {

            case .back: return .systemImage("arrow.left")
            case .close: return .systemImage("xmark")
            case .settings: return .systemImage("gear")
            case .ellipsis: return .systemImage("ellipsis")
            case .plus: return .systemImage("plus")
            case .bell: return .systemImage("bell")
            case .pencil: return .systemImage("pencil")
            case .filter(let isFilled): return .systemImage("line.3.horizontal.decrease.circle\(isFilled ? ".fill" : "")")
            case .trash: return .systemImage("trash")
            case .star(let isFilled): return .systemImage("star\(isFilled ? ".fill" : "")")

            }

        }

        var imageScale: CGFloat {

            switch self {

            case .close, .pencil: return 0.4
            default: return 0.5

            }

        }

        var notificationCount: Int {

            switch self {

            case .bell(let notificationCount): return notificationCount
            default: return 0

            }

        }

        var accessibilityLabel: String {

            switch self {

            case .back: return "Back"
            case .close: return "Close"
            case .settings: return "Settings"
            case .ellipsis: return "More options"
            case .plus: return "Add"
            case .bell: return "Notifications"
            case .pencil: return "Edit"
            case .filter: return "Filters"
            case .trash: return "Delete"
            case .star: return "Favorite"

            }

        }

        var accessibilityValue: String {

            guard case .bell(let count) = self else { return "" }
            return count == 1 ? "1 pending invite" : "\(count) pending invites"

        }

    }

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
