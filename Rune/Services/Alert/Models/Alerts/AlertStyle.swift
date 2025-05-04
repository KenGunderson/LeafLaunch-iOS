//
//  AlertStyle.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/6/24.
//

import SwiftUI

enum AlertStyle {
    
    case normal(AppAlertConfig)
    case textField(AppAlertConfig, action: (String) -> ())
    
    case success(message: String, buttonColor: Color, buttonTitleColor: Color, action: () -> ())
    
    case simpleError(message: String, action: () -> ())
    case simpleSuccess(message: String, action: () -> ())
    case forgotPassword(action: (String) -> ())
    
}

