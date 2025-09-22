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
        
        if let street2 = self.street2,
           !street2.isEmpty {
            string += " \(street2),"
        }
        
        return string + " \(self.city), \(self.state) \(self.zip)"
        
    }
    
    var fullFormattedAddress: String {
        
        var string = ""
        string += "\(self.street),"
        
        if let street2 = self.street2,
           !street2.isEmpty {
            string += " \(street2),"
        }
        
        string += "\n\(self.city), \(self.zip) \(self.state)"
        return string
        
    }
    
    func asJSON() -> [String: Any] {
    
        return [
            "street": self.street,
            "street_2": self.street2 ?? "",
            "city": self.city,
            "state": self.state,
            "zip": self.zip,
            "country": "USA"
        ]
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case street
        case street2 = "street_2"
        case city
        case state
        case zip
        
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
