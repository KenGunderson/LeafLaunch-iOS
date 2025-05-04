//
//  AppNumberFormatter.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 1/24/24.
//

import Foundation

protocol NumericConvertible {
    var nsNumber: NSNumber { get }
}

extension CGFloat: NumericConvertible {
    
    var nsNumber: NSNumber {
        return NSNumber(value: self)
    }
    
}

extension Float: NumericConvertible {
    
    var nsNumber: NSNumber {
        return NSNumber(value: self)
    }
    
}

extension Double: NumericConvertible {
    
    var nsNumber: NSNumber {
        return NSNumber(value: self)
    }
    
}

extension Int: NumericConvertible {
    
    var nsNumber: NSNumber {
        return NSNumber(value: self)
    }
    
}

struct AppNumberFormatter {

    static func format<T: NumericConvertible>(amount: T) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2

        return formatter.string(from: amount.nsNumber)!
        
    }
    
    static func formattedNumber<T: NumericConvertible>(amount: T) -> Double {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2

        let formattedNumber = formatter.string(from: amount.nsNumber)!
        return formatter.number(from: formattedNumber)?.doubleValue ?? 0
        
    }
    
    static func formattedAbbreviatedNumber<T: NumericConvertible>(amount: T) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        let doubleValueConversion = amount.nsNumber.doubleValue
        
        // Format

        let thousand = doubleValueConversion / 1000
        let million = doubleValueConversion / 1_000_000

        if million >= 1.0 {
            return "\(formatter.string(from: million.nsNumber)!)M"
        } else if thousand >= 1.0 {
            return "\(formatter.string(from: thousand.nsNumber)!)K"
        } else {
            return "\(formatter.string(from: amount.nsNumber)!)"
        }
        
    }
    
}
