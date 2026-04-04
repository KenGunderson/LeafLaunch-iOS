//
//  SpeechRecognitionPermissionServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/4/26.
//

import Combine

protocol SpeechRecognitionPermissionServiceProtocol: AnyObject, Loggable {
    
    var permissionGranted: Bool { get }
    var permissionGrantedPublisher: AnyPublisher<Bool, Never> { get }
    
    var shouldPromptForPermissions: Bool { get }
    var shouldPromptForPermissionsPublisher: AnyPublisher<Bool, Never> { get }
    
    func requestPermissionIfNeeded()
    func requestPermission()
    
}
