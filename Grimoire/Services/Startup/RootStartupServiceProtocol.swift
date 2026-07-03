//
//  RootStartupServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 2/16/26.
//

import Foundation

protocol RootStartupServiceProtocol: AnyObject {
    
    var isProduction: Bool { get }
    
    func setup(appDelegate: AppDelegate)
    func setLaunchState(_ state: LaunchScreenService.State)
    func markSplashAnimationCompleted()
    
    func start(
        onLaunchStateChanged: @escaping (LaunchScreenService.State) -> Void,
        onAuthError: @escaping (Error) -> Void,
        onNoNetwork: @escaping () -> Void,
        onHealthCheckResult: @escaping (_ requiresForceUpdate: Bool) -> Void
    )
    
}
