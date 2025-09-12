//
//  APIService+FeatureRequest.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/12/25.
//

extension APIService {
    
    // MARK: - FEATURE REQUESTS
    
    func submitFeatureRequest(userId: String,
                              request: String) async throws {
        
        let parameters: [String: Any] = [
            "user_id": userId,
            "message": request
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .featureRequest("")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}
