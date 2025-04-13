//
//  Ext+Primatives.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/5/25.
//

import Foundation

extension String: @retroactive Identifiable {
    
    public var id: Self {
        return self
    }
    
}

extension Bool: @retroactive Identifiable {
    
    public var id: Self {
        return self
    }
    
}

extension Int: @retroactive Identifiable {
    
    public var id: Self {
        return self.hashValue
    }
    
}

extension CGFloat: @retroactive Identifiable {
    
    public var id: Self {
        return self
    }
    
}

extension Float: @retroactive Identifiable {
    
    public var id: Self {
        return self
    }
    
}

extension Double: @retroactive Identifiable {
    
    public var id: Self {
        return self
    }
    
}

extension CGFloat {
    
    func truncate(places: Int) -> Double {
        
        let multiplier = pow(10.0, Double(places))
        return floor(Double(self) * multiplier) / multiplier
        
    }
    
}
