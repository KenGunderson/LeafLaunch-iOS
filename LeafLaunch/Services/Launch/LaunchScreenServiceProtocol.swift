//
//  LaunchServiceProtocol.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine

protocol LaunchScreenServiceProtocol: AnyObject, Loggable {
    
    var onLaunchStateChanged: CurrentValueSubject<LaunchScreenService.State, Never> { get }
    func setState(_ state: LaunchScreenService.State)
    
}
