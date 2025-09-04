//
//  ViewLifecycleService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import Combine

enum ViewLifecycleKey: String, Hashable {
    
    case home
    case clientList
    case mediaPreview
    case devSettings
    
}

final class ViewLifecycleService: ViewLifecycleServiceProtocol {
    
    internal let loggerName = "VIEW_LIFECYCLE"
    internal let loggerEmoji: String = "🔁"
    
    private var subjectMap: [ViewLifecycleKey: PassthroughSubject<Void, Never>] = [:]
    
    private(set) var onDidEnterBackground = CurrentValueSubject<String?, Never>(nil)
    private(set) var onDidBecomeActive = CurrentValueSubject<String?, Never>(nil)
    private(set) var onWillEnterForeground = CurrentValueSubject<String?, Never>(nil)
    
    init() {
        
        logInit()
        setupNotifications()
        
    }
    
    deinit {
        logDeinit()
    }
    
    func reload(for key: ViewLifecycleKey) {
        
        self.log(message: "Reloading Key: \(key.rawValue.convertNamingStyle(from: .camelCase, to: .screamingSnakeCase))")
        
        if let subject = self.subjectMap[key] {
            subject.send(())
        } else {
            
            let newSubject = PassthroughSubject<Void, Never>()
            self.subjectMap[key] = newSubject
            newSubject.send(())
            
        }
        
    }
    
    func reloadAll() {
        
        let subjects = self.subjectMap.values
        
        self.log(message: "Reloading all \(subjects.count) keys")
        
        for subject in subjects {
            subject.send(())
        }
        
    }
    
    func publisher(for key: ViewLifecycleKey) -> AnyPublisher<Void, Never> {
        
        var subject: PassthroughSubject<Void, Never>
        
        if let subjectMapSubject = self.subjectMap[key] {
            subject = subjectMapSubject
        } else {
            
            subject = PassthroughSubject<Void, Never>()
            self.subjectMap[key] = subject
            
        }
        
        return subject.eraseToAnyPublisher()
        
    }

    private func setupNotifications() {
        
        NotificationCenter
            .default
            .addObserver(forName: UIApplication.willEnterForegroundNotification,
                         object: nil,
                         queue: .main) { [weak self] notification in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.log(message: "will enter foreground")
                self?.onWillEnterForeground.send("\(notification.name.rawValue): \(UUID().uuidString)")
                
            }
            
        }
        
        NotificationCenter
            .default
            .addObserver(forName: UIApplication.didBecomeActiveNotification,
                         object: nil,
                         queue: .main) { [weak self] notification in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.log(message:"did become active")
                self?.onDidBecomeActive.send("\(notification.name.rawValue): \(UUID().uuidString)")
                
            }
            
        }

        NotificationCenter
            .default
            .addObserver(forName: UIApplication.didEnterBackgroundNotification,
                         object: nil,
                         queue: .main) { [weak self] notification in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.log(message:"did enter background")
                self?.onDidEnterBackground.send("\(notification.name.rawValue): \(UUID().uuidString)")
                
            }
            
        }
        
    }
    
}
