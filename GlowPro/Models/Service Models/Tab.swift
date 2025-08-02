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
    
    case clientDetails = "client_details"
    case tab2
    case tab3
    case tab4
    
    var title: String {
        switch self {
        case .clientDetails: return "Client"
        default: return self.rawValue.capitalized
        }
    }
    
    var unselectedIcon: String {
        switch self {
        case .clientDetails: return "house"
        case .tab2: return "list.bullet.clipboard"
        case .tab3: return "person.3"
        case .tab4: return "person.circle"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .clientDetails: return "house.fill"
        case .tab2: return "list.clipboard.fill"
        case .tab3: return "person.3.fill"
        case .tab4: return "person.circle.fill"
        }
    }
    
}
