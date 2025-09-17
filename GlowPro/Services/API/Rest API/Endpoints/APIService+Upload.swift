//
//  APIService+Upload.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/16/25.
//

import Foundation

extension APIService {
    
    // MARK: - UPLOAD IMAGE
    
    func uploadMedia(uploadMedia: UploadMedia) async throws -> String {
        
        let boundary = UUID().uuidString
        
        var fields: [String: MultipartValue] = [:]
        
        if let businessId = uploadMedia.businessId {
            fields["businessId"] = .text(businessId)
        }
        
        if let locationId = uploadMedia.locationId {
            fields["locationId"] = .text(locationId)
        }
        
        if let clientId = uploadMedia.clientId {
            fields["clientId"] = .text(clientId)
        }
        
        fields["file"] = .file(
            data: uploadMedia.data,
            filename: "TEMP_FILE_NAME.jpeg",
            mimeType: "image/jpeg"
        )
        
        let multipartRequest = MultipartBodyBuilder.makeBody(
            fields: fields,
            boundary: boundary
        )
        
        do {
            
            let data = try await buildMultipartRequest(
                method: .post,
                apiPath: .init(path: .uploadMedia("")),
                boundary: boundary,
                data: multipartRequest
            )
            
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
               let url: String = json["url"] as? String {
                
                return url
                
            }
            
            fatalError("No url found")
                        
        }
        catch {
            throw error
        }
        
    }
    
}
