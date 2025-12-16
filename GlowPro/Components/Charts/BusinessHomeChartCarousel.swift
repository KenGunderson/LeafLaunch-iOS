//
//  BusinessHomeChartCarousel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import SwiftUI

struct BusinessHomeChartCarousel: View {
    
    var body: some View {
        carouselView()
    }
    
    @ViewBuilder
    private func carouselView() -> some View {
        
        ScrollView(.horizontal) {
            
            LazyHStack(spacing: 8) {
                
                mediaBarChart()
                clientGrowthChart()
                employeeActivityChart()
                mediaTagMetricChart()
                clientIntakeMetricChart()
                
            }
            .scrollTargetLayout()
            
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollClipDisabled()
        .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
        
    }
    
    private func mediaBarChart() -> some View {
        
        MediaBarChart(data: MediaBarChartData.DUMMY_DATA)
            .containerRelativeFrame(.horizontal)
        
    }
    
    private func clientGrowthChart() -> some View {
        
        ClientGrowthLineChart(data: ClientGrowthData.DUMMY_DATA)
            .containerRelativeFrame(.horizontal)
        
    }
    
    private func employeeActivityChart() -> some View {
        
        EmployeeActivityBarChart(data: EmployeeActivityData.DUMMY_DATA)
            .containerRelativeFrame(.horizontal)
        
    }
    
    private func mediaTagMetricChart() -> some View {
        
        MetricScoreBaseChart(
            data: .init(
                title: "Untagged Media Score",
                subtitle: "Optimize tagging for better results.",
                description: "This metric shows the percentage of media that has not been tagged with a relevant keyword.",
                score: 50,
                statusText: "Average",
                statusColor: GPColor.iconYellow,
                gradientColors: [GPColor.iconRed, GPColor.iconYellow, GPColor.iconTeal, GPColor.iconGreen],
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
            ),
            actionTitle: "View Untagged Media",
            action: {
                
            }
        )
        .containerRelativeFrame(.horizontal)
        
    }
    
    private func clientIntakeMetricChart() -> some View {
        
        MetricScoreBaseChart(
            data: .init(
                title: "Client Intake Score",
                subtitle: "Client intake is a crucial metric for any business.",
                description: "This metric shows the percentage of clients that have more than their name field filled out.",
                score: 100,
                statusText: "Excellent",
                statusColor: GPColor.iconGreen,
                gradientColors: [GPColor.iconRed, GPColor.iconYellow, GPColor.iconTeal, GPColor.iconGreen],
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
            ),
            actionTitle: "View Untagged Media",
            action: {
                
            }
        )
        .containerRelativeFrame(.horizontal)
        
    }
    
}

#Preview {
    
    AppBaseView(horizontalPadding: .none) {
        BusinessHomeChartCarousel()
    }
    
}
