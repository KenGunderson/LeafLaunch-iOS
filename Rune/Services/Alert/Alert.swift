//
//  Alert.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 8/6/24.
//

import SwiftUI

struct Alert: Identifiable, Equatable {
    
    struct EnviornmentAlertConfig {
        
        let id: String = UUID().uuidString
        let style: EnviornmentAlertStyle
        
    }
    
    enum EnviornmentAlertStyle {
        
        typealias Action = (() -> ())
        
        case noNetwork(Action)
        case healthCheck(Action)
        case forceUpdate(Action)
        
    }
    
    enum AlertStyle: Equatable {
        
        case appAlert(AppAlertConfig)
        case textfield(config: AppAlertConfig, action: ((String) -> ()))
        case card(AppCardConfig)
        case loadingIndicator(AppLoadingConfig)
        case simpleLoadingIndicator
        case enviornmentAlert(EnviornmentAlertConfig)
        
        static func == (lhs: AlertStyle, rhs: AlertStyle) -> Bool {
            
            switch (lhs, rhs) {
            case (.appAlert(let lhsConfig), .appAlert(let rhsConfig)): return lhsConfig == rhsConfig
            case (.textfield(let lhsConfig, _), .textfield(let rhsConfig, _)):  return lhsConfig == rhsConfig
            case (.card(let lhsConfig), .card(let rhsConfig)): return lhsConfig == rhsConfig
            case (.loadingIndicator(let lhsConfig), .loadingIndicator(let rhsConfig)): return lhsConfig == rhsConfig
            case (.enviornmentAlert(let lhsAlert), .enviornmentAlert(let rhsAlert)): return lhsAlert.id == rhsAlert.id
            case (.simpleLoadingIndicator, .simpleLoadingIndicator): return true
            default: return false
            }
            
        }
        
    }
    
    let id: String
    let alert: Alert.AlertStyle
    
    init(_ alert: Alert.AlertStyle,
         id: String = UUID().uuidString) {
        
        self.id = id
        self.alert = alert
        
    }
    
}
