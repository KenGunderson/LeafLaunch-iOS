//
//  APIService+Health.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import Foundation

extension APIService {
    
    // MARK: - HEALTH
    
    func getHealth() async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .get,
                apiPath: .init(path: .health)
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}
