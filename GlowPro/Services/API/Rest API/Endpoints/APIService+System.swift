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
            
            let result: [LegalItem] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getFrequentlyAskedQuestions() async throws -> [FAQViewModel.FAQItemSection] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .system("faq"))
            )
            
            let result: [FAQViewModel.FAQItemSection] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
}
