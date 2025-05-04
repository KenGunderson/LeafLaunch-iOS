//
//  NormalHalfCircleProgressView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/13/25.
//

import SwiftUI

struct HalfCircleProgressView: View {
    
    var progress: CGFloat
    var lineWidth: CGFloat = 24
    var title: String? = nil
    var titleFont: Theme.FontKey = .TITLE_T10
    var titleColor: ColorSource = Style.shared.textColor(.title)
    var fillColor: ColorSource = Style.shared.accent
    var trackColor: ColorSource = Style.shared.background(.quaternary)
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            BottomHalfCircleShape()
                .stroke(style: StrokeStyle(
                    lineWidth: self.lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                ))
                .foregroundStyle(self.trackColor.source())

            BottomHalfCircleShape()
                .trim(from: 0.0, to: self.progress)
                .stroke(style: StrokeStyle(
                    lineWidth: self.lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                ))
                .foregroundStyle(self.fillColor.source())
            
            if let title {
                
                Text(title)
                    .appFont(with: self.titleFont)
                    .foregroundStyle(self.titleColor.source())
                    .contentTransition(.numericText(value: self.progress))
                    .animation(.smooth(duration: 0.5), value: self.progress)
                
            }
            
        }
        .aspectRatio(1.85, contentMode: .fit)
        .compositingGroup()
        
    }
    
}

fileprivate struct BottomHalfCircleShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // The arc’s radius = half the total width
        let radius = rect.width / 2
        
        // Place the circle’s center at the bottom of the view,
        // so the semicircle extends upward.
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        return path
    }
    
}

#Preview {
    
    @Previewable @State var progress: CGFloat = 0.5
    
    AppBaseView {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            HalfCircleProgressView(
                progress: progress,
                lineWidth: 18,
                title: "\(Int(progress * 100))%"
            )
            
            HalfCircleProgressView(
                progress: progress,
                fillColor: .linearGradient(.init(colors: [.indigo, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            
        }
        .padding(.horizontal, Style.shared.spacing(.custom(64)))
        
    }
    .appOnTapGesture {
        
        withAnimation(.spring()) {
            progress = CGFloat.random(in: 0...1)
        }
        
    }
    
}
