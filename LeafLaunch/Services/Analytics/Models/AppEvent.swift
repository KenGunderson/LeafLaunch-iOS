//
//  AppEvent.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 10/01/23.
//

enum AppEvent: AnalyticsEvent {
    
    enum AuthEvent {
        
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
            
            // Preserve the existing authentication analytics names.
            return EventData(
                name: "onboarding_\(eventName)",
                properties: properties
            )
            
        }
        
    }
    
    case auth(AuthEvent)
    
    var eventType: EventType {
        return .app
    }
    
    var eventData: EventData {
        
        switch self {
        case .auth(let event): return event.data
        }
        
    }
        
}
