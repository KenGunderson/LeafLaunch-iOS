//
//  Ext+String.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 9/10/25.
//

import Foundation

extension String {

    nonisolated func trimmed() -> Self {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    nonisolated var nilIfEmpty: String? {
        return self.isEmpty ? nil : self
    }

    func isValidEmail() -> Bool {
        
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        
        do {
            
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: utf16.count)
            return regex.firstMatch(in: self, options: [], range: range) != nil
            
        } catch {
            
            print("Invalid regex: \(error.localizedDescription)")
            return false
            
        }
        
    }
    
}
