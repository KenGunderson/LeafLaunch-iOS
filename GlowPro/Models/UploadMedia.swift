//
//  UploadMedia.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/16/25.
//

import Foundation

struct UploadMedia: Codable {
    
    let data: Data
    let businessId: String?
    let locationId: String?
    let clientId: String?
    
    init(data: Data,
         businessId: String? = nil,
         locationId: String? = nil,
         clientId: String? = nil) {
        
        self.data = data
        self.businessId = businessId
        self.locationId = locationId
        self.clientId = clientId
        
    }
    
}
