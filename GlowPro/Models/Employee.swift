//
//  Employee.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/1/25.
//

import Foundation
 
struct Employee: Identifiable,
                 Codable,
                 Mockable {
    
    let id: String
    let name: String
    
}

extension Employee {
    
    static func DUMMY_DATA() -> Employee {
        
        return .init(
            id: UUID().uuidString,
            name: "Juan Employee"
        )
        
    }
    
}

