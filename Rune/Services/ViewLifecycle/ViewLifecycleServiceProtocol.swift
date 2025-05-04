//
//  ViewLifecycleServiceProtocol.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine

protocol ViewLifecycleServiceProtocol: AnyObject {
    
    var onShouldReloadView: CurrentValueSubject<Int, Never> { get }
    var onDidEnterBackground: CurrentValueSubject<String?, Never> { get }
    var onDidBecomeActive: CurrentValueSubject<String?, Never> { get }
    var onWillEnterForeground: CurrentValueSubject<String?, Never> { get }
    
    func triggerReload()
    
}
