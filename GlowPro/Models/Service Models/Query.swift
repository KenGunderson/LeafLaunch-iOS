//
//  Query.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/19/24.
//

import Foundation

struct Query {
    
    enum Bucket: String {
        
        case user
        
    }
    
    enum Order: String {
        
        case acending = "ASC"
        case decending = "DESC"
        
    }
    
    var limit: Int
    var offset: Int
    var query: String?
    var order: Order?
    var inviteCode: String?
    
    static let defaultLimit: Int = 25
    
    init(limit: Int = 1000,
         offset: Int = 0,
         query: String? = nil,
         rating: Int? = nil,
         inviteCode: String? = nil,
         order: Order? = nil) {
        
        self.limit = limit
        self.offset = offset
        self.query = query
        self.inviteCode = inviteCode
        self.order = order
        
    }
    
    func asDict() -> [String : String] {
     
        var dict: [String : String?] = [:]
        
        dict["limit"] = "\(self.limit)"
        dict["offset"] = "\(self.offset)"
        dict["query"] = self.query
        dict["order"] = self.order?.rawValue
        dict["invite_code"] = self.inviteCode
        
        return dict
            .compact()
         
    }
    
}
