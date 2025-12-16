//
//  EmployeeActivityData.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import Foundation

struct EmployeeActivityData: Identifiable, Codable {
    
    let id: String
    let name: String
    let kind: MediaType
    let count: Int
    
    init(id: String = UUID().uuidString,
         name: String,
         kind: MediaType,
         count: Int) {
        
        self.id = id
        self.name = name
        self.kind = kind
        self.count = count
        
    }
    
}

extension EmployeeActivityData {
    
    static let DUMMY_DATA: [Self] = [
        
        .init(name: "Dr. Smith", kind: .collage, count: 12),
        .init(name: "Dr. Smith", kind: .image, count: 40),
        .init(name: "Dr. Smith", kind: .diagram, count: 5),
        
        .init(name: "Sarah J", kind: .collage, count: 25),
        .init(name: "Sarah J", kind: .image, count: 65),
        .init(name: "Sarah J", kind: .diagram, count: 15),
        
        .init(name: "Nurse Joy", kind: .collage, count: 18),
        .init(name: "Nurse Joy", kind: .image, count: 35),
        .init(name: "Nurse Joy", kind: .diagram, count: 8),
        
        .init(name: "Dr. Lee", kind: .collage, count: 10),
        .init(name: "Dr. Lee", kind: .image, count: 28),
        .init(name: "Dr. Lee", kind: .diagram, count: 12),
        
    ]
    
}
