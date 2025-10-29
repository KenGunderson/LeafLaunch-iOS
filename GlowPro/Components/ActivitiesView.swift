//
//  ActivityView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/19/25.
//

import SwiftUI

struct LazyActivitiesView: View {
    
    private let activityDict: [Date: [Activity]]
    private let loadNextBatch: (() -> Void)?
    
    init(activities: [Activity],
         loadNextBatch: (() -> Void)? = nil) {
                
        self.activityDict = Dictionary(
            grouping: activities,
            by: \.createdAtNoTimestamp
        )
        
        self.loadNextBatch = loadNextBatch
        
    }
    
    var body: some View {
        
        LazyVStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            ForEach(activityDict.keys.sorted(by: { $0 > $1}), id: \.date) { key in
                
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
        
        LazyVStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text(date)
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            activityList(activities: activities)
            
        }
        
    }
    
    private func activityList(activities: [Activity]) -> some View {
        
        LazyVStack(spacing: Style.shared.spacing(.small)) {
            
            ForEach(activities, id: \.id) { activity in
                
                ActivityView(activity: activity)
                    .onAppear {
                        
                        if activity.id == activities.last?.id {
                            loadNextBatch?()
                        }
                        
                    }
                
            }
            
        }
        
    }
    
}

struct ActivitiesView: View {
    
    private let activityDict: [Date: [Activity]]
    private let loadNextBatch: (() -> Void)?
    
    init(activities: [Activity],
         loadNextBatch: (() -> Void)? = nil) {
                
        self.activityDict = Dictionary(
            grouping: activities,
            by: \.createdAtNoTimestamp
        )
        
        self.loadNextBatch = loadNextBatch
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            ForEach(activityDict.keys.sorted(by: { $0 > $1}), id: \.date) { key in
                
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
                    .onAppear {
                        
                        if activity.id == activities.last?.id {
                            loadNextBatch?()
                        }
                        
                    }
                
            }
            
        }
        
    }
    
}

#Preview {
    
    ActivitiesView(
        activities: [
            .init(
                id: "1",
                clientId: "",
                authorId: "",
                businessId: MockModels.ID.business1,
                locationId: MockModels.ID.location1,
                activityType: .clientUpdated,
                createdAt: Date().addingTimeInterval(-73497493).toISO()
            ),
            .init(
                id: "2",
                clientId: "",
                authorId: "",
                businessId: MockModels.ID.business1,
                locationId: MockModels.ID.location1,
                activityType: .formCreated,
                createdAt: Date().addingTimeInterval(-4379743).toISO()
            ),
            .init(
                id: "3",
                clientId: "",
                authorId: "",
                businessId: MockModels.ID.business1,
                locationId: MockModels.ID.location1,
                activityType: .quickNote,
                createdAt: Date().addingTimeInterval(-4379743).toISO()
            ),
            .init(
                id: "4",
                clientId: "",
                authorId: "",
                businessId: MockModels.ID.business1,
                locationId: MockModels.ID.location1,
                activityType: .businessUpdated,
                createdAt: Date().toISO()
            ),
            .init(
                id: "5",
                clientId: "",
                authorId: "",
                businessId: MockModels.ID.business1,
                locationId: MockModels.ID.location1,
                activityType: .noteCreated,
                createdAt: Date().toISO()
            ),
            .init(
                id: "6",
                clientId: "",
                authorId: "",
                businessId: MockModels.ID.business1,
                locationId: MockModels.ID.location1,
                activityType: .mediaAdded,
                createdAt: Date().toISO()
            ),
        ]
    )
    .padding(.horizontal, .medium)
    
}
