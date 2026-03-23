//
//  ViewLifecycleService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import SwiftUI
import Combine

enum ViewLifecycleKey: String, Hashable, Sendable {
    
    case home
    
    case businessHome
    case locationHome
    case clientHome
    
    case clientList
    case noteList
    case formList
    
    case mediaPreview
    case mediaGallery
    
    case subscriptionManage
    
    case settings
    
    case devSettings
    
}

@MainActor
final class ViewLifecycleService: ViewLifecycleServiceProtocol {
    
    internal let loggerName = "VIEW_LIFECYCLE"
    internal let loggerEmoji: String = "🔁"
    
    private var subjectMap: [ViewLifecycleKey: PassthroughSubject<Void, Never>] = [:]
    private var notificationObservers: [NSObjectProtocol] = []
    
    private(set) var onDidEnterBackground = CurrentValueSubject<String?, Never>(nil)
    private(set) var onDidBecomeActive = CurrentValueSubject<String?, Never>(nil)
    private(set) var onWillEnterForeground = CurrentValueSubject<String?, Never>(nil)
    
    init() {
        
        logInit()
        setupNotifications()
        
    }
    
    deinit {
        
        self.notificationObservers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
        
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
    
    func reload(for keys: [ViewLifecycleKey]) {
        
        for key in keys {
            
            self.log(message: "Reloading Key: \(key.rawValue.convertNamingStyle(from: .camelCase, to: .screamingSnakeCase))")
            
            if let subject = self.subjectMap[key] {
                subject.send(())
            } else {
                
                let newSubject = PassthroughSubject<Void, Never>()
                self.subjectMap[key] = newSubject
                newSubject.send(())
                
            }
            
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
        
        let willEnterForegroundObserver = NotificationCenter
            .default
            .addObserver(forName: UIApplication.willEnterForegroundNotification,
                         object: nil,
                         queue: .main) { [weak self] notification in
                
                let notificationName = notification.name.rawValue
                
                Task { @MainActor [weak self] in
                    
                    self?.log(message: "will enter foreground")
                    self?.onWillEnterForeground.send("\(notificationName): \(UUID().uuidString)")
                    
                }
                
            }
        
        self.notificationObservers.append(willEnterForegroundObserver)
        
        let didBecomeActiveObserver = NotificationCenter
            .default
            .addObserver(forName: UIApplication.didBecomeActiveNotification,
                         object: nil,
                         queue: .main) { [weak self] notification in
                
                let notificationName = notification.name.rawValue
                
                Task { @MainActor [weak self] in
                    
                    self?.log(message:"did become active")
                    self?.onDidBecomeActive.send("\(notificationName): \(UUID().uuidString)")
                    
                }
                
            }
        
        self.notificationObservers.append(didBecomeActiveObserver)
        
        let didEnterBackgroundObserver = NotificationCenter
            .default
            .addObserver(forName: UIApplication.didEnterBackgroundNotification,
                         object: nil,
                         queue: .main) { [weak self] notification in
                
                let notificationName = notification.name.rawValue
                
                Task { @MainActor [weak self] in
                    
                    self?.log(message:"did enter background")
                    self?.onDidEnterBackground.send("\(notificationName): \(UUID().uuidString)")
                    
                }
                
            }
        
        self.notificationObservers.append(didEnterBackgroundObserver)
        
    }
    
}
