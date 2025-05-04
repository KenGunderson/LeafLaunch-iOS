//
//  PermissionsServiceProtocol.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine

protocol PermissionsServiceProtocol: AnyObject {
    
    var shouldShowPermissionView: Bool { get }
    var shouldShowPermissionViewPublisher: AnyPublisher<Bool, Never> { get }
    
    var cameraPermissionService: CameraPermissionServiceProtocol { get }
    var mediaPermissionService: MediaPermissionServiceProtocol { get }
    var pushNotificationPermissionService: PushNotificationPermissionServiceProtocol { get }
    var appTrackingPermissionService: AppTrackingPermissionServiceProtocol { get }
    
    func validatePermissions()
    func requestPermission(_ permission: Permission)
    
}
