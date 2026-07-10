//
//  WhatsNew.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 3/7/25.
//

import Foundation

struct WhatsNewItem: Identifiable, Equatable {
    
    static func == (lhs: WhatsNewItem, rhs: WhatsNewItem) -> Bool {
        lhs.id == rhs.id
    }
    
    struct Item: Identifiable {
        
        let id: String = UUID().uuidString
        let title: String
        let message: String
        let icon: String
        let foregroundStyle: ColorSource
        
        init(title: String,
             message: String,
             icon: String,
             foregroundStyle: ColorSource = .foreground(.primary)) {
            
            self.title = title
            self.message = message
            self.icon = icon
            self.foregroundStyle = foregroundStyle
            
        }
        
    }
    
    let id: String = UUID().uuidString
    let version: SemanticVersion
    let items: [Self.Item]
    
}

struct SemanticVersion: Comparable, CustomStringConvertible {
    
    let major: Int
    let minor: Int
    let patch: Int

    // Parse a version string like "1.2.3"
    init(_ versionString: String) {
        
        let parts = versionString.split(separator: ".").compactMap { Int($0) }
        self.major = parts.count > 0 ? parts[0] : 0
        self.minor = parts.count > 1 ? parts[1] : 0
        self.patch = parts.count > 2 ? parts[2] : 0
        
    }
    
    // Conformance to Comparable.
    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        
        return lhs.patch < rhs.patch
        
    }
    
    var description: String {
        return "\(major).\(minor).\(patch)"
    }
    
}
