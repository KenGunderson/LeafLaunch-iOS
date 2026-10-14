//
//  UserDefaultsService.swift
//  LeafLaunch
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
    case didRateMyAppAlertShow
    case securityPinsDictionaryData
    case shouldHideScreenshots
        
}

final class UserDefaultsService: UserDefaultsServiceProtocol {

    private let style: any StyleProtocol
    
    internal let loggerName: String = "USER_DEFAULTS_SERVICE"
    internal let loggerEmoji: String = "🔐"
    
    @AppStorage(Setting.theme.rawValue) private(set) var theme: AvailableTheme = .light {
        didSet {
            self.themePublisher.send(self.theme)
        }
    }
    
    @AppStorage(Setting.didRateMyAppAlertShow.rawValue) private(set) var didRateMyAppAlertShow: Bool = false {
        didSet {
            self.didRateMyAppAlertShowPublisher.send(self.didRateMyAppAlertShow)
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
    var didRateMyAppAlertShowPublisher = PassthroughSubject<Bool, Never>()
    var securityPinsDictionaryDataPublisher = PassthroughSubject<Data?, Never>()
    var shouldHideScreenshotsPublisher = PassthroughSubject<Bool, Never>()
    
    init(style: any StyleProtocol) {

        self.style = style
        
        self.logInit()
        self.style.updateTheme(self.theme.theme())
        
        self.themePublisher.send(self.theme)
        self.didRateMyAppAlertShowPublisher.send(self.didRateMyAppAlertShow)
        self.securityPinsDictionaryDataPublisher.send(self.securityPinsDictionaryData)
        self.shouldHideScreenshotsPublisher.send(self.shouldHideScreenshots)
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func set(theme: AvailableTheme) {
        
        self.theme = theme
        self.style.updateTheme(self.theme.theme())
        
    }
    
    func set(didRateMyAppAlertShow: Bool) {
        self.didRateMyAppAlertShow = didRateMyAppAlertShow
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
    
    func resetDevFlags() {
        
        self.set(didRateMyAppAlertShow: false)
        self.set(shouldHideScreenshots: false)
        
    }
    
    func getSecurityPinForBusinessId(_ businessId: String) -> String? {
        
        let key = self.securityPinsDictionaryData
        
        if let dict = try? JSONSerialization.jsonObject(with: key ?? Data(), options: []) as? [String: String?] {
            return dict[businessId] ?? nil
        }
        
        return nil
        
    }
    
    @MainActor
    func logout() async {
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        Setting
            .allCases
            .forEach {
                UserDefaults.standard.removeObject(forKey: $0.rawValue)
            }
        
        // Manually Reset
        
        self.set(shouldHideScreenshots: false)
        
    }
    
}
