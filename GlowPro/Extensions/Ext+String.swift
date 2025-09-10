//
//  Ext+String.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/10/25.
//

extension String {
    
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
