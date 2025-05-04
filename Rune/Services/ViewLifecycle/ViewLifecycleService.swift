//
//  ViewLifecycleService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import Combine

final class ViewLifecycleService: ViewLifecycleServiceProtocol {
    
    private(set) var onShouldReloadView = CurrentValueSubject<Int, Never>(0)
    private(set) var onDidEnterBackground = CurrentValueSubject<String?, Never>(nil)
    private(set) var onDidBecomeActive = CurrentValueSubject<String?, Never>(nil)
    private(set) var onWillEnterForeground = CurrentValueSubject<String?, Never>(nil)
    
    private let logger = GrimoireLogger.service(.lifecycle)
    
    init() {
        
        self.logger.logInit()
        setupNotifications()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func triggerReload() {
        onShouldReloadView.send(onShouldReloadView.value + 1)
    }
    
    private func setupNotifications() {
        
        NotificationCenter
            .default
            .addObserver(forName: UIApplication.willEnterForegroundNotification,
                         object: nil,
                         queue: .main) { [weak self] notification in
            
            DispatchQueue.main.async {
                
                self?.logger.debugMessage("will enter foreground")
                self?.onWillEnterForeground.send("\(notification.name.rawValue): \(UUID().uuidString)")
                
            }
            
        }
        
        NotificationCenter
            .default
            .addObserver(forName: UIApplication.didBecomeActiveNotification,
                         object: nil,
                         queue: .main) { [weak self] notification in
            
            DispatchQueue.main.async {
                
                self?.logger.debugMessage("did become active")
                self?.onDidBecomeActive.send("\(notification.name.rawValue): \(UUID().uuidString)")
                
            }
            
        }

        NotificationCenter
            .default
            .addObserver(forName: UIApplication.didEnterBackgroundNotification,
                         object: nil,
                         queue: .main) { [weak self] notification in
            
            DispatchQueue.main.async {
                
                self?.logger.debugMessage("did enter background")
                self?.onDidEnterBackground.send("\(notification.name.rawValue): \(UUID().uuidString)")
                
            }
            
        }
        
    }
    
}
