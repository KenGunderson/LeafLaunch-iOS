//
//  MediaBarChart.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import Charts
import SwiftUI

struct MediaBarChart: View {
    
    let data: [MediaBarChartData]
    
    private var totalMediaPeriod: Int {
        self.data.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        
        BaseChartCardView(
            title: "Photo Activity Volume",
            attributedMessage: AttributedText {
                
                Text("\(self.totalMediaPeriod) ")
                    .font(Style.shared.font(.HEADER_2))
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Text("captures")
                    .font(Style.shared.font(.BODY_2))
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
            },
            description: "Media Captured in the last 6 weeks") {
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    chart()
                    legend()
                    
                }
                
            }
        
    }
    
    private func chart() -> some View {
        
        Chart {
            
            ForEach(self.data) { item in
                
                BarMark(
                    x: .value("Week", item.weekLabel),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(by: .value("Kind", item.mediaKind.rawValue))
                
            }
            
        }
        .chartForegroundStyleScale([
            MediaType.image.rawValue: MediaType.image.color,
            MediaType.collage.rawValue: MediaType.collage.color,
            MediaType.diagram.rawValue: MediaType.diagram.color
        ])
        .chartYAxis {
            
            AxisMarks(position: .leading) { value in
                
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.gray.opacity(0.3))
                
                AxisValueLabel() {
                    
                    if let intValue = value.as(Int.self) {
                        
                        Text("\(intValue)")
                            .appFont(with: .BODY_2)
                            .foregroundStyle(Style.shared.textColor(.body).source())
                        
                    }
                    
                }
                
            }
            
        }
        .chartXAxis {
            
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
            
            LegendItem(
                title: "Photo",
                color: .color(MediaType.image.color),
                image: ActivityCategory.camera.icon
            )
            
            LegendItem(
                title: "Collage",
                color: .color(MediaType.collage.color),
                image: ActivityCategory.collage.icon
            )
            
            LegendItem(
                title: "Diagram",
                color: .color(MediaType.diagram.color),
                image: ActivityCategory.form.icon
            )
            
        }
        .frame(maxWidth: .infinity, alignment: .center)
        
    }
    
}

#Preview {
    
    MediaBarChart(data: MediaBarChartData.DUMMY_DATA)
        .padding(.horizontal, .large)
    
}
