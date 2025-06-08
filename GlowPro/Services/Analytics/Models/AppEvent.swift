//
//  AppEvent.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 10/01/23.
//

enum AppEvent: AnalyticsEvent {
    
    enum OnboardingEvent {
        
        case signupIntent
        case loginIntent
        case appleLoginIntent
        case appleSignupIntent
        case forgotPasswordIntent
        case forgotPassword(email: String)
        
        var data: EventData {
            
            var eventName: String
            var properties: [String: Any]?
            
            switch self {
            case .signupIntent: eventName = "signup_intent"
            case .appleSignupIntent: eventName = "apple_signup_intent"
            case .loginIntent: eventName = "login_intent"
            case .appleLoginIntent: eventName = "apple_login_intent"
            case .forgotPasswordIntent: eventName = "forgot_password_intent"
            case .forgotPassword(let email):
                
                eventName = "forgot_password"
                properties = ["email" : email]
             
            }
            
            return EventData(
                name: "onboarding.\(eventName)",
                properties: properties
            )
            
        }
        
    }
    
    enum MainEvent {
        
        case tabIntent(tab: Tab)
        
        var data: EventData {
            
            var eventName: String
            var properties: [String: Any]?
            
            switch self {
            case .tabIntent(let tab):
                
                eventName = "tab_intent"
                properties = ["tab" : tab.rawValue]
             
            }
            
            return EventData(
                name: "main.\(eventName)",
                properties: properties
            )
            
        }
        
    }
    
    case onboarding(OnboardingEvent)
    case main(MainEvent)
    
    var eventType: EventType {
        return .app
    }
    
    var eventData: EventData {
        
        switch self {
        case .onboarding(let event): return event.data
        case .main(let event): return event.data
        }
        
    }
        
}
