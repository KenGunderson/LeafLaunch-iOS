//
//  APIService+System.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/28/25.
//

extension APIService {
    
    // MARK: - LEGAL
    
    func getLegalInformation(context: String) async throws -> [LegalItem] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .system("legal-information")),
                queryParameters: ["context": context]
            )
            
            let result: [String: [LegalItem]] = try parseData(data: data)
            
            if let legalInformation = result["legal_information"] {
                return legalInformation
            }
            else {
                throw APIError.serverError(statusCode: 401, errorMessage: "missing legal information")
            }
            
        }
        catch {
            throw error
        }
        
    }
    
}
