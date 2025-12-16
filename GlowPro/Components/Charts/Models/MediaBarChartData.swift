//
//  MediaBarChartData.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import Foundation

struct MediaBarChartData: Identifiable, Codable {

    let id: String
    let weekLabel: String
    let mediaKind: MediaType
    let count: Int
    
    init(id: String = UUID().uuidString,
         weekLabel: String,
         mediaKind: MediaType,
         count: Int) {
        
        self.id = id
        self.weekLabel = weekLabel
        self.mediaKind = mediaKind
        self.count = count
        
    }

}

extension MediaBarChartData {
    
    static let DUMMY_DATA: [Self] = [
        
        // Week 1: Oct 1
        .init(weekLabel: "Oct 1", mediaKind: .collage, count: 15),
        .init(weekLabel: "Oct 1", mediaKind: .image, count: 45),
        .init(weekLabel: "Oct 1", mediaKind: .diagram, count: 8),

        // Week 2: Oct 8
        .init(weekLabel: "Oct 8", mediaKind: .collage, count: 18),
        .init(weekLabel: "Oct 8", mediaKind: .image, count: 52),
        .init(weekLabel: "Oct 8", mediaKind: .diagram, count: 12),

        // Week 3: Oct 15
        .init(weekLabel: "Oct 15", mediaKind: .collage, count: 12),
        .init(weekLabel: "Oct 15", mediaKind: .image, count: 38),
        .init(weekLabel: "Oct 15", mediaKind: .diagram, count: 5),

        // Week 4: Oct 22
        .init(weekLabel: "Oct 22", mediaKind: .collage, count: 25),
        .init(weekLabel: "Oct 22", mediaKind: .image, count: 60),
        .init(weekLabel: "Oct 22", mediaKind: .diagram, count: 15),
        
    ]
    
}
