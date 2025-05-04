//
//  ConnectivityService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
import Network
import SwiftUI

final class ConnectivityService: ConnectivityServiceProtocol {
    
    private let networkMonitor = NWPathMonitor()
    private(set) var onHasNetworkConnection = CurrentValueSubject<Bool, Never>(true)
    
    private let logger = GrimoireLogger.service(.connectivity)
    
    init() {
        
        self.logger.logInit()
        
        self.networkMonitor.pathUpdateHandler = { [weak self] path in
            
            guard let self = self else { return }
            self.setNetworkConnection(connection: path.status == .satisfied)
            
        }
        
        self.networkMonitor.start(queue: DispatchQueue.global())
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func setNetworkConnection(connection: Bool) {
        
        Task { @MainActor in
            
            withAnimation {
                onHasNetworkConnection.send(connection)
            }
            
        }
        
    }
    
}
