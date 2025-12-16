//
//  ClientGrowthLineChart.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import Charts
import SwiftUI

struct ClientGrowthLineChart: View {
    
    let data: [ClientGrowthData]
    
    // Brand color
    let lineColor = ActivityCategory.client.color
    
    var body: some View {
        
        BaseChartCardView(
            title: "Client Growth (30 Days)",
            attributedMessage: AttributedText {
                
                Text("Total Active Clients")
                    .font(Style.shared.font(.BODY_2))
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
            },
            description: "Clients joined over the past 30 days") {
                chart()
            }
        
    }
    
    private func chart() -> some View {
        
        let gradint = LinearGradient(
            colors: [
                self.lineColor.opacity(0.3),
                self.lineColor.opacity(0.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
     
        return Chart {
            
            ForEach(self.data) { point in
                
                AreaMark(
                    x: .value("Date", point.dateLabel),
                    y: .value("Clients", point.activeClients)
                )
                .foregroundStyle(gradint)
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", point.dateLabel),
                    y: .value("Clients", point.activeClients)
                )
                .foregroundStyle(lineColor)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3))

                PointMark(
                    x: .value("Date", point.dateLabel),
                    y: .value("Clients", point.activeClients)
                )
                .foregroundStyle(self.lineColor)
                .symbol(Circle())
                .symbolSize(40)
                
            }
            
        }
        .chartYAxis {
            
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) {
                
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.gray.opacity(0.3))
                
                AxisValueLabel()
                    .font(Style.shared.font(.BODY_2))
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
            }
            
        }
        .chartXAxis {
            
            AxisMarks { value in
                
                if let str = value.as(String.self) {
                    if str == data.first?.dateLabel || str == data.last?.dateLabel {
                        
                        AxisValueLabel()
                            .font(Style.shared.font(.BODY_2))
                            .foregroundStyle(Style.shared.textColor(.body).source())
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    
    ClientGrowthLineChart(data: ClientGrowthData.DUMMY_DATA)
        .padding(.horizontal, .large)
    
}
