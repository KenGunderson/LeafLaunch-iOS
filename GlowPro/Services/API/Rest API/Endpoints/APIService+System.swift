//
//  APIService+System.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/28/25.
//

extension APIService {
    
    // MARK: - COMPANY STATS
    
    func getCompanyStats(interval: CompanyStatInterval) async throws -> CompanyStats {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .system("company/stats")),
                queryParameters: ["interval": interval.rawValue]
            )
            
            let result: CompanyStats = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
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
    
    func reportScreenshot(businessId: String) async throws {
        
        do {
            
            _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .system("report/screenshot")),
                parameters: ["business_id": businessId]
            )
            
            return
            
        }
        catch {
            throw error
        }
        
    }
    
}
