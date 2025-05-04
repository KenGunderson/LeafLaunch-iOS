//
//  FullScreenCover.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/16/24.
//

enum FullScreenCover: Identifiable, Hashable, Equatable {

    case devSettings

    var id: String {
        return String(self.hashValue)
    }
    
    static func == (lhs: FullScreenCover, rhs: FullScreenCover) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case .devSettings: return hasher.combine(1)
        }
        
    }
    
}
