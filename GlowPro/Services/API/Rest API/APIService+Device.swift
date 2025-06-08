//
//  APIService+Device.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 10/8/23.
//

import Foundation

extension APIService {
    
    func registerDevice(token: String,
                        userId: String) async throws {
        
        let parameters: [String : Any] = [
            "device_token": token
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .device("")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}
