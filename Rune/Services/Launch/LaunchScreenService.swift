//
//  LaunchService.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine

final class LaunchScreenService: LaunchScreenServiceProtocol {
    
    enum State {
        
        case loading
        case completed
        
    }

    private(set) var onLaunchStateChanged = CurrentValueSubject<LaunchScreenService.State, Never>(.loading)
    private let logger = RuneLogger.service(.launch)
    
    init() {
        self.logger.logInit()
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func setState(_ state: LaunchScreenService.State) {
        self.onLaunchStateChanged.send(state)
    }
    
}
