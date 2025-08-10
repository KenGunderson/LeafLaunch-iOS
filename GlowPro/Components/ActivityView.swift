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
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(date)
                .appFont(with: .TITLE_4)
                .padding(.bottom, .small)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            activityList(activities: activities)
            
        }
        
    }
    
    private func activityList(activities: [Activity]) -> some View {
        
        ForEach(activities, id: \.id) { activity in
            
            let hideLine = (activity.id == activities.last?.id)
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(alignment: .center) {
                    
                    pin()
                    activityItem(activity)
                        .frame(height: 12)
                    
                }
                
                if !hideLine {
                    
                    Rectangle()
                        .fill(Style.shared.background(.quaternary).source())
                        .frame(width: 2, height: 16)
                        .padding(.leading, 3.5)
                    
                }
                
            }
            
        }
        
    }
    
    private func activityItem(_ activity: Activity) -> some View {
        
        Text(activity.title)
            .appFont(with: .TITLE_3)
            .foregroundStyle(Style.shared.textColor(.body).source())
        
    }
    
    private func pin() -> some View {
     
        Circle()
            .fill(Style.shared.accent.source())
            .frame(width: 10, height: 10)
        
    }
    
}

#Preview {
    
    ActivitiesView(
        activities: [
            .init(
                id: "1",
                title: "Called Client",
                clientId: "",
                employeeId: "",
                createdAt: Date().addingTimeInterval(-73497493).toISO()
            ),
            .init(
                id: "2",
                title: "Intake Form Filled",
                clientId: "",
                employeeId: "",
                createdAt: Date().addingTimeInterval(-4379743).toISO()
            ),
            .init(
                id: "3",
                title: "Ate At Outback",
                clientId: "",
                employeeId: "",
                createdAt: Date().addingTimeInterval(-4379743).toISO()
            ),
            .init(
                id: "4",
                title: "Did Something Else",
                clientId: "",
                employeeId: "",
                createdAt: Date().toISO()
            ),
            .init(
                id: "5",
                title: "Built Legos",
                clientId: "",
                employeeId: "",
                createdAt: Date().toISO()
            ),
            .init(
                id: "6",
                title: "Ate Some Soup",
                clientId: "",
                employeeId: "",
                createdAt: Date().toISO()
            ),
        ]
    )
    .padding(.horizontal, .large)
    
}
