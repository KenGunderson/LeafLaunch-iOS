//
//  APIService+BusinessS.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/11/25.
//

import Foundation

extension APIService {
    
    // MARK: - BUSINESS SETTINGS
    
    func getBusinessSettings(businessId: String) async throws -> BusinessSetting {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .businessSetting("business/\(businessId)"))
            )
            
            let result: BusinessSetting = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func updateShouldReportScreenshot(businessId: String,
                                      shouldReportScreenshot: Bool) async throws {
        
        let parameters: [String: Any] = [
            "should_report_screenshot": shouldReportScreenshot
        ]
        
        do {
            
            let _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .businessSetting("\(businessId)/should-report-screenshot")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}
