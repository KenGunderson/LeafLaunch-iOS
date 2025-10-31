//
//  UploadMedia.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/16/25.
//

import Foundation

struct UploadMedia: Codable {
    
    enum ContentType: String, Codable {
        
        case pdf = "application/pdf"
        case image = "image/jpeg"
        
        var mimeType: String {
            switch self {
            case .pdf: return "application/pdf"
            case .image: return "image/jpeg"
            }
        }
        
    }
    
    let data: Data
    let businessId: String?
    let locationId: String?
    let clientId: String?
    let mediaType: MediaType
    let contentType: ContentType
    
    init(data: Data,
         businessId: String? = nil,
         locationId: String? = nil,
         clientId: String? = nil,
         mediaType: MediaType = .image,
         contentType: ContentType = .image) {
        
        self.data = data
        self.businessId = businessId
        self.locationId = locationId
        self.clientId = clientId
        self.mediaType = mediaType
        self.contentType = contentType
        
    }
    
}
