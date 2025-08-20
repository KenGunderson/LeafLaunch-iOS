//
//  Address.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/1/25.
//

import Foundation

struct Address: Codable,
                Equatable,
                Hashable,
                Mockable {
    
    let street: String
    let street2: String?
    let city: String
    let state: String
    let zip: String
    
    var shortFormattedAddress: String {
        
        var string = ""
        string += "\(self.street),"
        
        if let street = self.street2 {
            string += " \(street),"
        }
        
        return string + " \(self.city), \(self.state) \(self.zip)"
        
    }
    
    var fullFormattedAddress: String {
        
        var string = ""
        string += "\(self.street),"
        
        if let street = self.street2 {
            string += " \(street),"
        }
        
        string += "\n\(self.city), \(self.zip) \(self.state)"
        return string
        
    }
    
}

extension Address {
    
    static func DUMMY_DATA() -> Address {
        return .init(
            street: "502 East Oceanfront",
            street2: nil,
            city: "Newport Beach",
            state: "CA",
            zip: "92661"
        )
    }
    
}
