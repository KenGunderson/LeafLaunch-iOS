//
//  AppDelegateService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
import UserNotifications
import UIKit

final class AppDelegateService: AppDelegateServiceProtocol {
    
    internal let loggerName: String = "APP_DELEGATE_SERVICE"
    internal let loggerEmoji: String = "📱"
    
    @Published private(set) var deviceToken: String?
    var deviceTokenPublisher: AnyPublisher<String?, Never> {
        return self.$deviceToken.eraseToAnyPublisher()
    }
    
    // prefix with on
    var onNotificationPublisher = PassthroughSubject<UNNotification?, Never>()
    var onTappedNotificationPublisher = PassthroughSubject<UNNotification?, Never>()
    var appWillTerminatePublisher: PassthroughSubject<Void, Never> = .init()
    
    private var appDelegate: AppDelegate!
    private var cancelBag: CancelBag!
        
    init() {
        self.logInit()
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(appDelegate: AppDelegate) {
        
        self.appDelegate = appDelegate
        self.cancelBag = CancelBag()
        
        self.appDelegate
            .deviceTokenPublisher
            .receiveOnMain()
            .sink { [weak self] deviceToken in
                self?.deviceToken = deviceToken
            }
            .store(in: &self.cancelBag)
        
        self.appDelegate
            .pushNotificationPublisher
            .receiveOnMain()
            .sink { [weak self] notification in
                self?.onNotificationPublisher.send(notification)
            }
            .store(in: &self.cancelBag)
        
        self.appDelegate
            .pushNotificationTappedPublisher
            .receiveOnMain()
            .sink { [weak self] notification in
                self?.onTappedNotificationPublisher.send(notification)
            }
            .store(in: &self.cancelBag)
        
        self.appDelegate
            .appWillTerminatePublisher
            .sink { [weak self] in
                self?.appWillTerminatePublisher.send()
            }
            .store(in: &self.cancelBag)
        
    }
    
    func clearNotification() {
        self.onNotificationPublisher.send(nil)
    }
    
}
