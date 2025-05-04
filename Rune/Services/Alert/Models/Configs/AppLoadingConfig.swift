//
//  AlertLoadingConfig.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/7/24.
//

import SwiftUI

struct AppLoadingConfig: Equatable {
        
    enum LoadStyle {
        
        case progressView(title: String)
        
    }
        
    let loadStyle: LoadStyle
    
    init(loadStyle: LoadStyle) {
        self.loadStyle = loadStyle
    }
    
    // Equatable
    
    static func == (lhs: AppLoadingConfig, rhs: AppLoadingConfig) -> Bool {
        
        switch (lhs.loadStyle, rhs.loadStyle) {
        case (.progressView(let lhsTitle), .progressView(let rhsTitle)):
            
            return lhsTitle == rhsTitle
            
        }
        
    }
    
}
