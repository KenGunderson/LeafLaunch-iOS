//
//  UserDefaultsService.swift
//  GlowPro
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
    case didViewChecklistCompletionSheet
    case lastViewedWhatsNewVersion
    case didRateMyAppAlertShow
    case impersonatedUser
    case securityPinsDictionaryData
    case shouldHideScreenshots
        
}

final class UserDefaultsService: UserDefaultsServiceProtocol {
    
    internal let loggerName: String = "USER_DEFAULTS_SERVICE"
    internal let loggerEmoji: String = "🔐"
    
    @AppStorage(Setting.theme.rawValue) private(set) var theme: AvailableTheme = .glowPro {
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
    
    @AppStorage(Setting.didViewChecklistCompletionSheet.rawValue) private(set) var didViewChecklistCompletionSheet: Bool = false {
        didSet {
            self.didViewChecklistCompletionSheetPublisher.send(self.didViewChecklistCompletionSheet)
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
    
    @AppStorage(Setting.securityPinsDictionaryData.rawValue) private(set) var securityPinsDictionaryData: Data? {
        didSet {
            self.securityPinsDictionaryDataPublisher.send(self.securityPinsDictionaryData)
        }
    }
    
    @AppStorage(Setting.shouldHideScreenshots.rawValue) private(set) var shouldHideScreenshots: Bool = false {
        didSet {
            self.shouldHideScreenshotsPublisher.send(self.shouldHideScreenshots)
        }
    }
    
    var themePublisher = PassthroughSubject<AvailableTheme, Never>()
    var didCompleteOnboardingPublisher = PassthroughSubject<Bool, Never>()
    var didCompletePermissionPublisher = PassthroughSubject<Bool, Never>()
    var didShowPermissionScreenPublisher = PassthroughSubject<Bool, Never>()
    var didViewChecklistCompletionSheetPublisher = PassthroughSubject<Bool, Never>()
    var lastViewedWhatsNewVersionPublisher = PassthroughSubject<String?, Never>()
    var didRateMyAppAlertShowPublisher = PassthroughSubject<Bool, Never>()
    var impersonatingUserDataPublisher = PassthroughSubject<Data?, Never>()
    var securityPinsDictionaryDataPublisher = PassthroughSubject<Data?, Never>()
    var shouldHideScreenshotsPublisher = PassthroughSubject<Bool, Never>()
    
    init() {
        
        self.logInit()
        Style.shared.updateTheme(self.theme.theme())
        
        self.themePublisher.send(self.theme)
        self.didCompleteOnboardingPublisher.send(self.didCompleteOnboarding)
        self.didCompletePermissionPublisher.send(self.didCompletePermission)
        self.didViewChecklistCompletionSheetPublisher.send(self.didViewChecklistCompletionSheet)
        self.lastViewedWhatsNewVersionPublisher.send(self.lastViewedWhatsNewVersion)
        self.didRateMyAppAlertShowPublisher.send(self.didRateMyAppAlertShow)
        self.impersonatingUserDataPublisher.send(self.impersonatingUserData)
        self.securityPinsDictionaryDataPublisher.send(self.securityPinsDictionaryData)
        self.shouldHideScreenshotsPublisher.send(self.shouldHideScreenshots)
        
    }
    
    deinit {
        self.logDeinit()
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
    
    func set(didViewChecklistCompletionSheet: Bool) {
        self.didViewChecklistCompletionSheet = didViewChecklistCompletionSheet
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
    
    func set(securityPin: String?, businessId: String) {
        
        let key = self.securityPinsDictionaryData
        
        if var dict = try? JSONSerialization.jsonObject(with: key ?? Data(), options: []) as? [String: String?] {
            
            dict[businessId] = securityPin
            
            if let data = try? JSONEncoder().encode(dict) {
                self.securityPinsDictionaryData = data
            }
            
        } else {
            
            var dict = [String: String?]()
            dict[businessId] = securityPin
            
            if let data = try? JSONEncoder().encode(dict) {
                self.securityPinsDictionaryData = data
            }
            
        }
        
    }
    
    func set(shouldHideScreenshots: Bool) {
        self.shouldHideScreenshots = shouldHideScreenshots
    }
    
    func getSecurityPinForBusinessId(_ businessId: String) -> String? {
        
        let key = self.securityPinsDictionaryData
        
        if let dict = try? JSONSerialization.jsonObject(with: key ?? Data(), options: []) as? [String: String?] {
            return dict[businessId] ?? nil
        }
        
        return nil
        
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
            
            self.set(impersonatedUser: nil)
            self.set(lastViewedWhatsNewVersion: nil)
            self.set(didCompleteOnboarding: false)
            self.set(shouldHideScreenshots: false)
            
        }
        
    }
    
}
