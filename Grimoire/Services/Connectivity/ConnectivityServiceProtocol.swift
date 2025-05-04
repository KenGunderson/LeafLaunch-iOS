//
//  ConnectivityServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine

protocol ConnectivityServiceProtocol: AnyObject {
    
    var onHasNetworkConnection: CurrentValueSubject<Bool, Never> { get }
    func setNetworkConnection(connection: Bool)
    
}
