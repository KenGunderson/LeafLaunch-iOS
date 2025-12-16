//
//  ClientGrowthData.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import Foundation

struct ClientGrowthData: Identifiable {
    
    let id: String
    let dateLabel: String
    let activeClients: Int
    
    init(id: String = UUID().uuidString,
         dateLabel: String,
         activeClients: Int) {
        
        self.id = id
        self.dateLabel = dateLabel
        self.activeClients = activeClients
        
    }
    
}

extension ClientGrowthData {
    
    static let DUMMY_DATA: [Self] = [
     
        .init(dateLabel: "Oct 1",  activeClients: 120),
        .init(dateLabel: "Oct 8",  activeClients: 145),
        .init(dateLabel: "Oct 15", activeClients: 162),
        .init(dateLabel: "Oct 22", activeClients: 158),
        .init(dateLabel: "Oct 29", activeClients: 185),
        .init(dateLabel: "Oct 30", activeClients: 210)
        
    ]
    
}

