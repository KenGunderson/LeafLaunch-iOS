//
//  Tab.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/17/24.
//

import Foundation

enum Tab: String, CaseIterable, Selectable {

    var id: String { self.rawValue }
    var description: String { self.title }

    case tab1
    case tab2
    case tab3

    var title: String {

        switch self {
        case .tab1: return String(localized: "Store")
        case .tab2: return String(localized: "Menu")
        case .tab3: return String(localized: "Account")
        }

    }

    var unselectedIcon: String {
        switch self {
        case .tab1: return "house"
        case .tab2: return "list.bullet.clipboard"
        case .tab3: return "person.circle"
        }
    }

    var selectedIcon: String {
        switch self {
        case .tab1: return "house.fill"
        case .tab2: return "list.clipboard.fill"
        case .tab3: return "person.circle.fill"
        }
    }

}
