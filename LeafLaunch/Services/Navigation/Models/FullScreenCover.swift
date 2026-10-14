//
//  FullScreenCover.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import Foundation

enum FullScreenCover: Identifiable, Hashable, Equatable {

    case settings
    case devSettings

    var id: String {
        return String(self.hashValue)
    }

    static func == (lhs: FullScreenCover, rhs: FullScreenCover) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {

        switch self {
        case .devSettings: return hasher.combine(0)
        case .settings: return hasher.combine(2)
        }

    }

}
