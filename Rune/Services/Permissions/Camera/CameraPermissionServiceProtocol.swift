//
//  CameraPermissionServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/14/24.
//

import Combine

protocol CameraPermissionServiceProtocol: AnyObject {
    
    var permissionGranted: Bool { get }
    var permissionGrantedPublisher: AnyPublisher<Bool, Never> { get }
    
    var shouldPromptForPermissions: Bool { get }
    var shouldPromptForPermissionsPublisher: AnyPublisher<Bool, Never> { get }

    func requestPermissionIfNeeded()
    func requestPermission()
    
}
