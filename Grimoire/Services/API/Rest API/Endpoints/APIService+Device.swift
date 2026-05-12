//
//  APIService+Device.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 10/8/23.
//

import Foundation

extension APIService {
    
    @concurrent
    func registerDevice(token: String,
                        userId: String) async throws {
        
        let parameters: [String : Any] = [
            "device_token": token
        ]
        .compact()
        
        let _ = try await buildRequest(
            method: .post,
            apiPath: .init(path: .device("")),
            parameters: parameters
        )
        
    }
    
}
