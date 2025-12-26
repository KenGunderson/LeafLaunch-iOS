//
//  APILogResponse.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 5/15/25.
//

import Foundation

public struct APILogResponse: Sendable {
    
    public let method: String
    public let path: String
    public let statusCode: Int
    public let headers: [String: String]
    public let queryParameters: [String: String]
    public let body: [String : Any]
    public let date = Date()
    private let responseData: Data?
    
    public var error: Error?
    
    public var responseJSON: [String: Any]? {
        
        if let responseData,
           let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
            return json
        }
        
        return nil
        
    }
    
    public init(method: String,
                path: String,
                statusCode: Int,
                headers: [String : String],
                queryParameters: [String : String],
                body: [String : Any],
                responseData: Data?) {
        
        self.method = method
        self.path = path
        self.statusCode = statusCode
        self.headers = headers
        self.queryParameters = queryParameters
        self.body = body
        self.responseData = responseData
        
    }
    
}
