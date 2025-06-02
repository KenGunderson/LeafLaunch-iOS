//
//  UserDefaultsService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import Combine

// NOTES: -
/// If we want to use the app group we have set up to pass data to other extensions.
/// we can use this; notice the store being passed into the group
//@AppStorage(Setting.SomeSetting.rawValue, store: UserDefaults(suiteName: "group.com.gentlepath.app")) private(set) var someSettings: String? {
//    didSet {
//        WidgetCenter.shared.reloadAllTimelines()
//    }
//}

enum Setting: String, CaseIterable {
    
    case theme
    case didCompleteOnboarding
    case didCompletePermission
    case lastViewedWhatsNewVersion
    case didRateMyAppAlertShow
    case impersonatedUser
        
}

final class UserDefaultsService: UserDefaultsServiceProtocol {
    
    @AppStorage(Setting.theme.rawValue) private(set) var theme: AvailableTheme = .lightCyan {
        didSet {
            self.themePublisher.send(self.theme)
        }
    }
    
    @AppStorage(Setting.didCompleteOnboarding.rawValue) private(set) var didCompleteOnboarding: Bool = false {
        didSet {
            self.didCompleteOnboardingPublisher.send(self.didCompleteOnboarding)
        }
    }
    
    @AppStorage(Setting.didCompletePermission.rawValue) private(set) var didCompletePermission: Bool = false {
        didSet {
            self.didCompletePermissionPublisher.send(self.didCompletePermission)
        }
    }
    
    @AppStorage(Setting.lastViewedWhatsNewVersion.rawValue) private(set) var lastViewedWhatsNewVersion: String? {
        didSet {
            self.lastViewedWhatsNewVersionPublisher.send(self.lastViewedWhatsNewVersion)
        }
    }
        
    @AppStorage(Setting.didRateMyAppAlertShow.rawValue) private(set) var didRateMyAppAlertShow: Bool = false {
        didSet {
            self.didRateMyAppAlertShowPublisher.send(self.didRateMyAppAlertShow)
        }
    }
    
    @AppStorage(Setting.impersonatedUser.rawValue) private(set) var impersonatingUserData: Data? {
        didSet {
            self.impersonatingUserDataPublisher.send(self.impersonatingUserData)
        }
    }
    
    var themePublisher = PassthroughSubject<AvailableTheme, Never>()
    var didCompleteOnboardingPublisher = PassthroughSubject<Bool, Never>()
    var didCompletePermissionPublisher = PassthroughSubject<Bool, Never>()
    var didShowPermissionScreenPublisher = PassthroughSubject<Bool, Never>()
    var lastViewedWhatsNewVersionPublisher = PassthroughSubject<String?, Never>()
    var didRateMyAppAlertShowPublisher = PassthroughSubject<Bool, Never>()
    var impersonatingUserDataPublisher = PassthroughSubject<Data?, Never>()
    
    private let logger = GrimoireLogger.service(.userDefaults)

    init() {
        
        self.logger.logInit()
        Style.shared.updateTheme(self.theme.theme())
        
        self.themePublisher.send(self.theme)
        self.didCompleteOnboardingPublisher.send(self.didCompleteOnboarding)
        self.didCompletePermissionPublisher.send(self.didCompletePermission)
        self.lastViewedWhatsNewVersionPublisher.send(self.lastViewedWhatsNewVersion)
        self.didRateMyAppAlertShowPublisher.send(self.didRateMyAppAlertShow)
        self.impersonatingUserDataPublisher.send(self.impersonatingUserData)
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func set(theme: AvailableTheme) {
        
        self.theme = theme
        Style.shared.updateTheme(self.theme.theme())
        
    }
    
    func set(didCompleteOnboarding: Bool) {
        self.didCompleteOnboarding = didCompleteOnboarding
    }

    func set(didCompletePermission: Bool) {
        self.didCompletePermission = didCompletePermission
    }
    
    func set(lastViewedWhatsNewVersion: String?) {
        self.lastViewedWhatsNewVersion = lastViewedWhatsNewVersion
    }
    
    func set(didRateMyAppAlertShow: Bool) {
        self.didRateMyAppAlertShow = didRateMyAppAlertShow
    }
    
    func set(impersonatedUser: ImpersonatingUser?) {
        
        if let impersonatedUser {
            
            if let data = try? JSONEncoder().encode(impersonatedUser) {
                self.impersonatingUserData = data
            }
            
        } else {
            
            self.impersonatingUserData = nil
            
        }
        
    }
    
    func logout() async {
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        DispatchQueue.main.async {
         
            Setting
                .allCases
                .forEach {
                    UserDefaults.standard.removeObject(forKey: $0.rawValue)
                }
            
            // Manually Reset
            
            self.set(didCompleteOnboarding: false)
            self.set(didCompletePermission: false)
            self.set(impersonatedUser: nil)
            self.set(lastViewedWhatsNewVersion: nil)
            
        }
        
    }
    
}
