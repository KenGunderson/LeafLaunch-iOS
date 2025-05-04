//
//  AppAlertConfig.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/6/24.
//

import SwiftUI

struct AppAlertConfig: Equatable {
    
    typealias ButtonAction = () -> ()
    
    let title: String
    let message: String?
    
    let primaryButtonTitle: String
    let primaryButtonAction: ButtonAction
    let primaryButtonBackgroundColor: ColorSource
    let primaryButtonTextColor: ColorSource
    
    let secondaryButtonTitle: String?
    let secondaryButtonAction: ButtonAction?
    let secondaryButtonBackgroundColor: ColorSource?
    let secondaryButtonTextColor: ColorSource?
    
    init(title: String,
         message: String? = nil,
         primaryButtonTitle: String,
         primaryButtonAction: @escaping ButtonAction,
         primaryButtonBackgroundColor: ColorSource = .color(.blue),
         primaryButtonTextColor: ColorSource = .color(.white),
         secondaryButtonTitle: String? = nil,
         secondaryButtonAction: ButtonAction? = nil,
         secondaryButtonBackgroundColor: ColorSource? = nil,
         secondaryButtonTextColor: ColorSource? = nil) {
        
        self.title = title
        self.message = message
        
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonAction = primaryButtonAction
        self.primaryButtonBackgroundColor = primaryButtonBackgroundColor
        self.primaryButtonTextColor = primaryButtonTextColor
        
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonAction = secondaryButtonAction
        self.secondaryButtonBackgroundColor = secondaryButtonBackgroundColor
        self.secondaryButtonTextColor = secondaryButtonTextColor
        
    }
    
    // Equatable
    
    static func == (lhs: AppAlertConfig, rhs: AppAlertConfig) -> Bool {
        lhs.title == rhs.title
    }
    
    // Static
    
    static func error(message: String,
                      action: @escaping () -> ()) -> Self {
        
        .init(
            title: "Oh No!",
            message: message,
            primaryButtonTitle: "Okay",
            primaryButtonAction: action,
            primaryButtonBackgroundColor: .color(.red)
        )
        
    }
    
    static func success(message: String,
                        action: @escaping () -> ()) -> Self {
        
        .init(
            title: "Success!",
            message: message,
            primaryButtonTitle: "Okay",
            primaryButtonAction: action,
            primaryButtonBackgroundColor: Style.shared.accent,
            primaryButtonTextColor: .color(.white)
        )
        
    }
    
}
