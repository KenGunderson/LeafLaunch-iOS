//
//  EnvironmentService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/13/24.
//

import Combine
import Foundation

final class EnvironmentService: EnvironmentServiceProtocol {
    
    internal let loggerName: String = "ENVIRONMENT_SERVICE"
    internal let loggerEmoji: String = "♻️"
    
    @Published private(set) var environment: AppEnvironment?
    var environmentPublisher: AnyPublisher<AppEnvironment?, Never> {
        return self.$environment.eraseToAnyPublisher()
    }
        
    init() {
        
        self.logInit()
        setup()
        
    }
    
    deinit {
        self.logDeinit()
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
        case "LOCALHOST": return .localhost
        default: return nil
        }
        
    }
    
}
