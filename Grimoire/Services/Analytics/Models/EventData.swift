//
//  EventData.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 10/01/23.
//

import UIKit

struct EventData: Equatable {
    
    let id: String = UUID().uuidString
    let createdAt: Date = Date()
    
    var name: String
    var properties: [String: Any]?
    
    init(name: String,
         properties: [String: Any]? = nil) {
        
        self.name = name
        self.properties = properties
        
    }
    
    // Equatable
    
    static func == (lhs: EventData, rhs: EventData) -> Bool {
        lhs.id == rhs.id
    }
    
}
