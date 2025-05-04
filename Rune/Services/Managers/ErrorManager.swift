//
//  ErrorManager.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/9/24.
//

import Foundation

/// Global Error Manager tied to the root view
///
/// Use `ErrorManager.shared` to access the shared instance of the error manager.
/// Call `setError(error:al/Users/sakohovaguimian/Desktop/Personal/GentlePath/GentlePath/Components/AlertertStyle:)` to set an error and its associated alert style.
///
/// Example:
/// ```swift
/// ErrorManager.shared.setError(
///     error: error,
///     alertStyle: .simpleError(
///         message: (self.error?.getMessageForError() ?? ""),
///         action: {
///             self.error = nil
///         }
///     )
/// )
/// ```
@Observable
class ErrorManager {
        
    static let shared = ErrorManager()
    
    var error: Error?
    var alertStyle: AlertStyle = .simpleSuccess(message: "", action: {})
    
    private init() {}
    
    func setError(error: Error,
                  alertStyle: AlertStyle) {
        
        self.error = error
        self.alertStyle = alertStyle
        
    }
    
}
