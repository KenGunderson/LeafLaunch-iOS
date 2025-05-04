//
//  AppError.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/10/23.
//

import Foundation

protocol AppCustomError {
    var message: String { get }
}

extension Error {
    
    func getMessageForError() -> String {
        
        if let appCustomError = self as? AppCustomError {
            return appCustomError.message
        }
        
        return self.localizedDescription
        
    }
    
}
