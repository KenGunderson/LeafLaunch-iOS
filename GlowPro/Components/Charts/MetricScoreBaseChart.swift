//
//  MetricScoreCard.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import SwiftUI

struct MetricScoreBaseChart: View {
    
    let data: MetricScoreData
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        
        ChartCard {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
                
                header()
                                
                VStack(alignment: .leading, spacing: Style.shared.spacing(.custom(6))) {
                    
                    scoreChart()
                    legend()
                    
                }
                .offset(y: 8)
                
                Spacer()
                                
                actionButton()
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
        }
        .frame(height: CHART_HEIGHT)
        .frame(maxHeight: CHART_HEIGHT)
        
    }
    
    private func header() -> some View {
        
        HStack(alignment: .top) {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                Text(self.data.title)
                    .appFont(with: .HEADER_2)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Text(self.data.subtitle)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .padding(.top, -Style.shared.spacing(.small))
                
                HStack(spacing: Style.shared.spacing(.extraSmall)) {

                    Text(String(format: "%.0f%%", self.data.score))
                        .appFont(with: .HEADER_2)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                    Text(self.data.statusText)
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(Style.shared.textColor(.titleInverted).source())
                        .padding(.horizontal, .small)
                        .padding(.vertical, .extraSmall)
                        .background(self.data.statusColor)
                        .clipShape(.capsule)
                        .padding(.leading, .custom(2))
                    
                }
                
                Text(self.data.description)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    .fixedSize(horizontal: false, vertical: true)
                
            }

        }
        
    }
    
    private func scoreChart() -> some View {
        
        GeometryReader { proxy in
            
            let dotSize: CGFloat = 20
            let inset: CGFloat = 2
            
            // 1. Calculate the specific travel range
            // Start X (0%) = Inset + Half Dot
            let startX = inset + (dotSize / 2)
            
            // End X (100%) = Width - Inset - Half Dot
            let endX = proxy.size.width - inset - (dotSize / 2)
            
            // The total distance the dot travels
            let travelDistance = endX - startX
            
            // current X = Start + (Total Distance * percentage)
            let currentX = startX + (travelDistance * CGFloat(self.data.score / 100.0))
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 99)
                    .fill(
                        LinearGradient(
                            colors: self.data.gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 24)

                Circle()
                    .fill(Color.white)
                    .frame(width: dotSize, height: dotSize)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 1)
                    .position(
                        x: currentX,
                        y: proxy.size.height / 2
                    )
                
            }
            
        }
        .frame(height: 24)
        .frame(maxHeight: 24)
        
    }
    
    private func legend() -> some View {
        
        let items = self.data.legend
            .sorted { $0.order < $1.order }
        
        return HStack(spacing: Style.shared.spacing(.small2)) {
            
            ForEach(0..<items.count, id: \.self) { index in
                
                let currentItem = items[index]
                
                LegendDot(
                    title: currentItem.label,
                    color: currentItem.color
                )
                
            }
            
        }
        .appFont(with: .TITLE_2)
        .foregroundStyle(Style.shared.textColor(.title).source())
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func actionButton() -> some View {
        
        CommonButton(
            style: .outline(lineWidth: 1.5),
            title: self.actionTitle,
            titleColor: .color(self.data.statusColor),
            backgroundStyle: .color(self.data.statusColor),
            verticalPadding: .small
        ) {
            
            self.action()
            
        }
        
    }
    
}

#Preview {
    
    MetricScoreBaseChart(
        data: .DUMMY_DATA,
        actionTitle: "View Clients") {
            print("Viewing Clients...")
        }
        .padding(.horizontal, .medium)
    
}
