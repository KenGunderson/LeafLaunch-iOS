//
//  OnboardingPage.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/19/24.
//

import Foundation

enum OnboardingPage: String, CaseIterable, Identifiable {
    
    var id: String { self.rawValue }
    
    case welcome
    case features
    case permission
    
}
