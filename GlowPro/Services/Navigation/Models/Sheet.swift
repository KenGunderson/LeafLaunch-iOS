//
//  Sheet.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import SwiftUI

enum Sheet: Identifiable, Hashable, Equatable {
    
    case whatsNew(WhatsNewItem)
    case permissions
    case businessEntry
    
    var id: String {
        return String(self.hashValue)
    }
    
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case .whatsNew: return hasher.combine(0)
        case .permissions: return hasher.combine(1)
        case .businessEntry: return hasher.combine(2)
        }
        
    }
    
}
