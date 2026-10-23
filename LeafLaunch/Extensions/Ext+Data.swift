//
//  Ext+Data.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 10/23/26.
//

import Foundation

nonisolated public extension Dictionary where Key == String, Value == Any? {

    func compact() -> [String : Any] {
        self.compactMapValues { $0 }
    }

}

nonisolated public extension Dictionary where Key == String, Value == String? {

    func compact() -> [String : String] {
        self.compactMapValues { $0 }
    }

}
