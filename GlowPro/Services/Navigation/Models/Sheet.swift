//
//  Sheet.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import SwiftUI

enum Sheet: Identifiable, Hashable, Equatable {
    
    case securityPin(context: SecurityPinInputViewModel.Context,
                     businessId: String,
                     completion: ((Bool) -> Void)?)
    
    case whatsNew(WhatsNewItem)
    case permissions
    
    var id: String {
        return String(self.hashValue)
    }
    
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case .securityPin(_, let businessId, _): return hasher.combine(businessId)
        case .whatsNew: return hasher.combine(1)
        case .permissions: return hasher.combine(2)
        }
        
    }
    
}
