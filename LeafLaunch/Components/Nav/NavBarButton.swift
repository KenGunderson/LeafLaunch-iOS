//
//  NavBarButton.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 8/12/25.
//

import SwiftUI

struct NavBarButton: View {

    @Environment(\.style) private var environmentStyle
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

        var smallerIcon: Bool {
            switch self {
            case .close, .pencil: return true
            default: return false
            }
        }

        var accessibilityTitle: String {

            switch self {
            case .back: return String(localized: "Back")
            case .close: return String(localized: "Close")
            case .settings: return String(localized: "Settings")
            case .ellipsis: return String(localized: "More options")
            case .plus: return String(localized: "Add")
            case .bell(let count): return count > 0 ? String(localized: "Notifications, \(count) unread") : String(localized: "Notifications")
            case .pencil: return String(localized: "Edit")
            case .filter: return String(localized: "Filter")
            case .trash: return String(localized: "Delete")
            case .star(let isFilled): return isFilled ? String(localized: "Remove favorite") : String(localized: "Add favorite")
            }

        }

    }

    private let style: Style
    private let foregroundColor: ColorSource
    private let action: () -> Void

    init(style: Style,
         foregroundColor: ColorSource = .text(.title),
         action: @escaping () -> Void) {

        self.style = style
        self.foregroundColor = foregroundColor
        self.action = action

    }

    var body: some View {

        let frame: CGFloat = self.style.smallerIcon ? 16 : 20

        self.style.icon
            .view(renderingMode: .template)
            .scaledToFit()
            .frame(width: frame, height: frame)
            .foregroundStyle(self.foregroundColor)
            .frame(minWidth: 44, minHeight: 44)
            .background(self.environmentStyle.background(.secondary), in: Circle())
            .contentShape(Circle())
            .asButton(scale: self.reduceMotion ? 1 : nil) {
                action()
            }
            .accessibilityLabel(self.style.accessibilityTitle)
            .overlay(alignment: .topTrailing) {

                switch self.style {
                case .bell(let notificationCount):

                    if notificationCount > 0 {
                        badge(count: notificationCount)
                    }

                default: EmptyView()
                }

            }

    }

    private func badge(count: Int) -> some View {

        let digitCount = max(1, String(count).count)

        return Text("\(count)")
            .appFont(with: .TITLE_1)
            .padding(.horizontal, horizontalPadding(for: digitCount))
            .padding(.vertical, 1.3)
            .foregroundStyle(self.environmentStyle.textColor(.button))
            .lineLimit(1)
            .background(.foreground(.primary))
            .clipShape(Capsule())
            .offset(x: 0, y: -3.5)
            .fixedSize(horizontal: true, vertical: false)
            .accessibilityHidden(true)

    }

    private func horizontalPadding(for digits: Int) -> CGFloat {

        // 1 digit ≈ circle, extra digits add more width
        switch digits {
        case 1: return 4
        case 2: return 4
        default: return CGFloat(4 + (digits - 2) * 2)
        }

    }

}

#Preview {

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
