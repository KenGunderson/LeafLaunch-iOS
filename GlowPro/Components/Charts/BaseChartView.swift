//
//  BaseChartView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/15/25.
//

import SwiftUI

let CHART_HEIGHT: CGFloat = 300

struct ChartCard<Content: View>: View {
    
    let content: () -> Content
    
    var body: some View {
        
        self.content()
            .padding(.large)
            .background(Color.white)
            .cornerRadius(.medium)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        
    }
    
}

struct BaseChartCardView<Content: View>: View {
    
    private let title: String
    private let attributedMessage: AttributedText
    private let description: String
    private let chartTopSpacing: CGFloat
    private let content: () -> Content
    
    init(title: String,
         attributedMessage: AttributedText,
         description: String,
         chartTopSpacing: CGFloat = 24,
         @ViewBuilder content: @escaping () -> Content) {
        
        self.title = title
        self.attributedMessage = attributedMessage
        self.description = description
        self.chartTopSpacing = chartTopSpacing
        self.content = content
        
    }
    
    var body: some View {
        
        ChartCard {
            
            VStack(alignment: .leading, spacing: self.chartTopSpacing) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(self.title)
                        .appFont(with: .HEADER_2)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                    self.attributedMessage
                        .padding(.top, 2)
                    
                    Text(self.description)
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .padding(.top, .small)
                    
                }
                
                self.content()
                
            }
            
        }
        .frame(height: CHART_HEIGHT)
        .frame(maxHeight: CHART_HEIGHT)
        
    }
    
}
