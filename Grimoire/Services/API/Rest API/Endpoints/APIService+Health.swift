//
//  APIService+Health.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import Foundation

extension APIService {
    
    // MARK: - HEALTH
    
    @concurrent
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
