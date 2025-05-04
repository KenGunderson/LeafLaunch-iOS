//
//  UserDefaultsServiceProtocol.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import Combine

protocol UserDefaultsServiceProtocol: AnyObject {
    
    var theme: AvailableTheme { get }
    var didCompleteOnboarding: Bool { get }
    var didShowPermissionScreen: Bool { get }
    var lastViewedWhatsNewVersion: String? { get }
    var didRateMyAppAlertShow: Bool { get }
    var impersonatingUserData: Data? { get }
    
    var themePublisher: PassthroughSubject<AvailableTheme, Never> { get }
    var didCompleteOnboardingPublisher: PassthroughSubject<Bool, Never> { get }
    var didShowPermissionScreenPublisher: PassthroughSubject<Bool, Never> { get }
    var lastViewedWhatsNewVersionPublisher: PassthroughSubject<String?, Never> { get }
    var didRateMyAppAlertShowPublisher: PassthroughSubject<Bool, Never> { get }
    var impersonatingUserDataPublisher: PassthroughSubject<Data?, Never> { get }
    
    func set(theme: AvailableTheme)
    func set(didCompleteOnboarding: Bool)
    func set(didShowPermissionScreen: Bool)
    func set(lastViewedWhatsNewVersion: String?)
    func set(didRateMyAppAlertShow: Bool)
    func set(impersonatedUser: ImpersonatingUser?)
    func logout() async
    
}
