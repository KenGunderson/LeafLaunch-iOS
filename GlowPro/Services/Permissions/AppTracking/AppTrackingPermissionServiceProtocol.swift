//
//  AppTrackingPermissionServiceProtocol.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine
import UIKit
import AppTrackingTransparency

protocol AppTrackingPermissionServiceProtocol: AnyObject, Loggable {
    
    var permissionGranted: Bool? { get }
    var permissionGrantedPublisher: AnyPublisher<Bool?, Never> { get }
    
    var shouldPromptForPermissions: Bool { get }
    var shouldPromptForPermissionsPublisher: AnyPublisher<Bool, Never> { get }
    
    var attStatus: ATTStatus? { get }
    var attStatusPublisher: AnyPublisher<ATTStatus?, Never> { get }
    
    func requestPermissionIfNeeded()
    func requestPermission()
    
}
