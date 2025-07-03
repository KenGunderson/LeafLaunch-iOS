//
//  OnboardingPageViewProtocol.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/19/24.
//

import SwiftUI

protocol OnboardingPageViewProtocol: View {
    
    var page: OnboardingPage { get }
    var onAppear: () -> Void { get }
    var onDismiss: () -> Void { get }
    
}
