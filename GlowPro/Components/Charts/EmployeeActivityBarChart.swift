//
//  EmployeeActivityBarChart.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import Charts
import SwiftUI

struct EmployeeActivityBarChart: View {
    
    let data: [EmployeeActivityData]
    
    private var totalActivity: Int {
        data.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        
        BaseChartCardView(
            title: "Practitioner Activity",
            attributedMessage: AttributedText {
                
                Text("\(self.totalActivity) ")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                Text("logged items")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
            },
            description: "Photos / Sessions Logged (Last 30 Days)",
            chartTopSpacing: 4,
            content: {
                
                VStack(spacing: Style.shared.spacing(.custom(6))) {
                    
                    chart()
                    legend()
                    
                }
                
            }
        )
        
    }
    
    private func chart() -> some View {
        
        Chart {
            
            ForEach(self.data) { item in
                
                BarMark(
                    x: .value("Count", item.count),
                    y: .value("Practitioner", item.name)
                )
                .foregroundStyle(by: .value("Kind", item.kind.rawValue))
                
            }
            
        }
        .chartForegroundStyleScale([
            MediaType.image.rawValue: MediaType.image.color,
            MediaType.collage.rawValue: MediaType.collage.color,
            MediaType.diagram.rawValue: MediaType.diagram.color
        ])
        .chartXAxis {
            
            AxisMarks(position: .bottom) { value in
                
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.gray.opacity(0.3))
                
                AxisValueLabel()
                    .font(Style.shared.font(.BODY_2))
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
            }
            
        }
        .chartYAxis {
            
            AxisMarks { value in
                
                AxisValueLabel()
                    .font(Style.shared.font(.BODY_2))
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
            }
            
        }
        .chartLegend(.hidden)
        
    }
    
    private func legend() -> some View {
        
        HStack(spacing: Style.shared.spacing(.medium)) {
            
            Spacer()
            
            ForEach(MediaType.DISPLAY_CASES, id: \.id) { type in
            
                LegendDot(
                    title: type.description,
                    color: type.color
                )
                
            }
            
            Spacer()
            
        }
        
    }
    
}

#Preview {
    
    EmployeeActivityBarChart(data: EmployeeActivityData.DUMMY_DATA)
        .padding(.horizontal, .large)
    
}
