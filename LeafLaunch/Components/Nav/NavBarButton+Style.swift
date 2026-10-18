//
//  NavBarButton+Style.swift
//  LeafLaunch
//

import SwiftUI

extension NavBarButton {

    enum Style: Hashable {

        case back
        case plainBack
        case close
        case settings
        case ellipsis
        case plus
        case bell(notificationCount: Int = 0)
        case pencil
        case filter(isFilled: Bool = false)
        case trash
        case star(isFilled: Bool = false)
        case heart(isFilled: Bool = false)
        case storeFavorites

        var icon: ImageSource {

            switch self {

            case .back: return .systemImage("arrow.left")
            case .plainBack: return .systemImage("chevron.left")
            case .close: return .systemImage("xmark")
            case .settings: return .systemImage("gear")
            case .ellipsis: return .systemImage("ellipsis")
            case .plus: return .systemImage("plus")
            case .bell: return .systemImage("bell")
            case .pencil: return .systemImage("pencil")
            case .filter(let isFilled): return .systemImage("line.3.horizontal.decrease.circle\(isFilled ? ".fill" : "")")
            case .trash: return .systemImage("trash")
            case .star(let isFilled): return .systemImage("star\(isFilled ? ".fill" : "")")
            case .heart(let isFilled): return .systemImage("heart\(isFilled ? ".fill" : "")")
            case .storeFavorites: return .systemImage("heart")

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

            case .back, .plainBack: return "Back"
            case .close: return "Close"
            case .settings: return "Settings"
            case .ellipsis: return "More options"
            case .plus: return "Add"
            case .bell: return "Notifications"
            case .pencil: return "Edit"
            case .filter: return "Filters"
            case .trash: return "Delete"
            case .star: return "Favorite"
            case .heart, .storeFavorites: return String(localized: "Favorite Products")

            }

        }

        var accessibilityValue: String {

            guard case .bell(let count) = self else { return "" }
            return count == 1 ? "1 pending invite" : "\(count) pending invites"

        }

    }

}
