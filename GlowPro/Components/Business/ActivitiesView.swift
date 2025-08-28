//
//  ActivityView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import SwiftUI

struct ActivitiesView: View {
    
    private let activityDict: [Date: [Activity]]
    
    init(activities: [Activity]) {
                
        self.activityDict = Dictionary(
            grouping: activities,
            by: \.createdAtNoTimestamp
        )
        
    }
    
    var body: some View {
        
        LazyVStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            ForEach(activityDict.keys.sorted(), id: \.date) { key in
                
                section(
                    date: key.formatted(date: .abbreviated, time: .omitted),
                    activities: activityDict[key] ?? []
                )
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        
    }
    
    private func section(date: String,
                         activities: [Activity]) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text(date)
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            activityList(activities: activities)
            
        }
        
    }
    
    private func activityList(activities: [Activity]) -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            ForEach(activities, id: \.id) { activity in
                ActivityView(activity: activity)
            }
            
        }
        
    }
    
}

#Preview {
    
    ActivitiesView(
        activities: [
            .init(
                id: "1",
                title: "Called Client",
                clientId: "",
                authorId: "",
                activityType: .clientUpdated,
                createdAt: Date().addingTimeInterval(-73497493).toISO()
            ),
            .init(
                id: "2",
                title: "Intake Form Filled",
                clientId: "",
                authorId: "",
                activityType: .formSubmitted,
                createdAt: Date().addingTimeInterval(-4379743).toISO()
            ),
            .init(
                id: "3",
                title: "Ate At Outback",
                clientId: "",
                authorId: "",
                activityType: .quickNote,
                createdAt: Date().addingTimeInterval(-4379743).toISO()
            ),
            .init(
                id: "4",
                title: "Did Something Else",
                clientId: "",
                authorId: "",
                activityType: .businessUpdated,
                createdAt: Date().toISO()
            ),
            .init(
                id: "5",
                title: "Built Legos",
                clientId: "",
                authorId: "",
                activityType: .noteAdded,
                createdAt: Date().toISO()
            ),
            .init(
                id: "6",
                title: "Ate Some Soup",
                clientId: "",
                authorId: "",
                activityType: .mediaAdded,
                createdAt: Date().toISO()
            ),
        ]
    )
    .padding(.horizontal, .medium)
    
}
