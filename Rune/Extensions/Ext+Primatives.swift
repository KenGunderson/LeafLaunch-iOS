//
//  Ext+Primatives.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/5/25.
//

extension Int: @retroactive Identifiable {
    
    public var id: Self {
        return self.hashValue
    }
    
}

extension String: @retroactive Identifiable {
    
    public var id: Self {
        return self
    }
    
}
