//
//  MetricScoreData.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import SwiftUI

struct MetricScoreData: Identifiable {
    
    struct LegendItem: Identifiable {
        
        let id: String
        let label: String
        let color: Color
        let order: Int
        
        init(id: String = UUID().uuidString,
             label: String,
             color: Color,
             order: Int) {
            
            self.id = id
            self.label = label
            self.color = color
            self.order = order
            
        }
        
    }
    
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let score: Double
    let statusText: String
    let statusColor: Color
    let gradientColors: [Color]
    let legend: [LegendItem]
    
    init(id: String = UUID().uuidString,
         title: String,
         subtitle: String,
         description: String,
         score: Double,
         statusText: String,
         statusColor: Color,
         gradientColors: [Color],
         legend: [LegendItem]) {
        
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.score = score
        self.statusText = statusText
        self.statusColor = statusColor
        self.gradientColors = gradientColors
        self.legend = legend
        
    }
    
}

extension MetricScoreData {
    
    static var DUMMY_DATA: Self {
        
        return .init(
            title: "This is a title",
            subtitle: "This is a subtitles",
            description: "This is the very long description that goes on and on and on... and on... and on... Trust me man",
            score: 0,
            statusText: "Good",
            statusColor: .green,
            gradientColors: [
                
                GPColor.iconRed,
                GPColor.iconYellow,
                GPColor.iconTeal,
                GPColor.iconGreen
                
            ],
            legend: [
                
                .init(
                    label: "Bad",
                    color: GPColor.iconRed,
                    order: 0
                ),
                .init(
                    label: "Average",
                    color: GPColor.iconYellow,
                    order: 1
                ),
                .init(
                    label: "Good",
                    color: GPColor.iconTeal,
                    order: 2
                ),
                .init(
                    label: "Excellent",
                    color: GPColor.iconGreen,
                    order: 3
                ),
                
            ]
        )
        
    }
    
}
