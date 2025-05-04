//
//  LaunchServiceProtocol.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine

protocol LaunchScreenServiceProtocol: AnyObject {
    
    var onLaunchStateChanged: CurrentValueSubject<LaunchScreenService.State, Never> { get }
    func setState(_ state: LaunchScreenService.State)
    
}
