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
        
        var body = Data()
        let boundary = UUID().uuidString

        if let businessId = uploadMedia.businessId {
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"businessId\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(businessId)\r\n".data(using: .utf8)!)
            
        }

        if let locationId = uploadMedia.locationId {
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"locationId\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(locationId)\r\n".data(using: .utf8)!)
            
        }

        if let clientId = uploadMedia.clientId {
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"clientId\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(clientId)\r\n".data(using: .utf8)!)
            
        }

        // File
        let fileName = "TEMP_FILE_NAME.jpeg"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(uploadMedia.data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        do {
            
            let data = try await buildMultipartRequest(
                method: .post,
                apiPath: .init(path: .uploadMedia("")),
                boundary: boundary,
                data: body
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
