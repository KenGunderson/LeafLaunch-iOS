//
//  LegalItem.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/28/25.
//


import Foundation

struct LegalItem: Identifiable, Codable, Equatable {
    
    var id: String
    var title: String
    var sections: [String]
    
    init(id: String = UUID().uuidString,
         title: String,
         sections: [String]) {
        
        self.id = id
        self.title = title
        self.sections = sections
        
    }
    
    init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = UUID().uuidString
        self.title = try container.decode(String.self, forKey: .title)
        self.sections = try container.decode([String].self, forKey: .sections)
        
    }
    
}