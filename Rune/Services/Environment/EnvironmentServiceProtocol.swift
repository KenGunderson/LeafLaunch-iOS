//
//  EnvironmentServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Foundation
import Combine

protocol EnvironmentServiceProtocol: AnyObject {
    
    var environment: AppEnvironment? { get }
    var environmentPublisher: AnyPublisher<AppEnvironment?, Never> { get }
    
    func setEnvironment(_ environment: AppEnvironment)
    
}
