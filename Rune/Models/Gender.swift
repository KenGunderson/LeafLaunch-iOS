//
//  Gender.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import Foundation

enum Gender: String,
             CaseIterable,
             Identifiable,
             Codable {
    
    case male
    case female
    case other
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other"
        }
    }
    
    var id: String {
        return self.rawValue
    }
    
}
