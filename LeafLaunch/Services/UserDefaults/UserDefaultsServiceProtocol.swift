//
//  UserDefaultsServiceProtocol.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import Combine

protocol UserDefaultsServiceProtocol: AnyObject, Sendable, Loggable {
    
    var theme: AvailableTheme { get }
    var didRateMyAppAlertShow: Bool { get }
    var securityPinsDictionaryData: Data? { get }
    var shouldHideScreenshots: Bool { get }
    
    var themePublisher: PassthroughSubject<AvailableTheme, Never> { get }
    var didRateMyAppAlertShowPublisher: PassthroughSubject<Bool, Never> { get }
    var securityPinsDictionaryDataPublisher: PassthroughSubject<Data?, Never> { get }
    var shouldHideScreenshotsPublisher: PassthroughSubject<Bool, Never> { get }
    
    func set(theme: AvailableTheme)
    func set(didRateMyAppAlertShow: Bool)
    func set(securityPin: String?, businessId: String)
    func set(shouldHideScreenshots: Bool)
    func resetDevFlags()
    @MainActor
    func logout() async
    
    func getSecurityPinForBusinessId(_ businessId: String) -> String?
    
}
