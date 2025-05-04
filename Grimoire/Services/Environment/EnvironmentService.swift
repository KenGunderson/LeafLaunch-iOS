//
//  EnvironmentService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
import Foundation

final class EnvironmentService: EnvironmentServiceProtocol {
    
    @Published private(set) var environment: AppEnvironment?
    var environmentPublisher: AnyPublisher<AppEnvironment?, Never> {
        return self.$environment.eraseToAnyPublisher()
    }
    
    private let logger = GrimoireLogger.service(.environment)
    
    init() {
        
        self.logger.logInit()
        setup()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func setEnvironment(_ environment: AppEnvironment) {
        self.environment = environment
    }
    
    private func setup() {
        
        let pListUrl = Constants.PList.url
        
        if let data = try? Data(contentsOf: pListUrl),
           let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) {
            
            if let dict = plist as? [String: Any],
               let envString = dict["Environment"] as? String,
               let env = parseEnv(env: envString) {
                
                self.environment = env
                
            } else {
                fatalError("NO ENV SET")
            }
            
        }
        
    }
    
    private func parseEnv(env: String) -> AppEnvironment? {
        
        switch env {
        case "DEVELOPMENT": return .development
        case "PRODUCTION": return .production
        default: return nil
        }
        
    }
    
}
