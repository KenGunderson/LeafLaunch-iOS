//
//  BusinessSetting.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/11/25.
//

import Foundation

struct BusinessSetting: Identifiable,
                        Equatable,
                        Hashable,
                        Codable,
                        Mockable {
    
    let id: String
    let businessId: String
    let shouldReportScreenshot: Bool
    
    init(id: String,
         businessId: String,
         shouldReportScreenshot: Bool) {
        
        self.id = id
        self.businessId = businessId
        self.shouldReportScreenshot = shouldReportScreenshot
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case businessId = "business_id"
        case shouldReportScreenshot = "should_report_screenshot"
        
    }
    
}

extension BusinessSetting {

    static func DUMMY_DATA() -> Self {
        
        let id = UUID().uuidString
        
        return .init(
            id: id,
            businessId: MockModels.ID.business1,
            shouldReportScreenshot: false
        )
        
    }
    
}
