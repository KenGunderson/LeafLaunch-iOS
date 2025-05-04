//
//  Tab.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/17/24.
//

import Foundation

enum Tab: String, CaseIterable {
    
    case tab1
    case tab2
    case tab3
    case tab4
    
    var title: String {
        return self.rawValue.capitalized
    }
    
    var unselectedIcon: String {
        switch self {
        case .tab1: return "house"
        case .tab2: return "list.bullet.clipboard"
        case .tab3: return "person.3"
        case .tab4: return "person.circle"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .tab1: return "house.fill"
        case .tab2: return "list.clipboard.fill"
        case .tab3: return "person.3.fill"
        case .tab4: return "person.circle.fill"
        }
    }
    
}
