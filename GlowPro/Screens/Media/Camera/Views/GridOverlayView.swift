//
//  GridOverlayView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/25/25.
//

import SwiftUI

public struct GridOverlay: View {

    private let divisions: Int
    private let lineColor: ColorSource
    private let lineOpacity: Double
    private let lineWidth: CGFloat
    private let inset: CGFloat
    private let showsOuterBorder: Bool
    private let dash: [CGFloat]?

    public init(divisions: Int = 3,
                lineColor: ColorSource = Style.shared.accent,
                lineOpacity: Double = 0.6,
                lineWidth: CGFloat = 2,
                inset: CGFloat = 0,
                showsOuterBorder: Bool = false,
                dash: [CGFloat]? = []) {

        self.divisions = max(1, divisions)
        self.lineColor = lineColor
        self.lineOpacity = lineOpacity
        self.lineWidth = lineWidth
        self.inset = inset
        self.showsOuterBorder = showsOuterBorder
        self.dash = dash
    }

    // MARK: Body

    public var body: some View {
        
        GeometryReader { proxy in
            
            let size = proxy.size
            let stepWidth = size.width / CGFloat(self.divisions)
            let stepHeight = size.height / CGFloat(self.divisions)

            ZStack {

                // Vertical lines
                
                Path { path in
                    
                    guard self.divisions > 1 else { return }
                    
                    for i in 1..<self.divisions {
                        
                        let x = stepWidth * CGFloat(i)
                        path.move(to: CGPoint(x: x, y: self.inset))
                        path.addLine(to: CGPoint(x: x, y: size.height - self.inset))
                        
                    }
                    
                }
                .stroke(style: StrokeStyle(
                    lineWidth: self.lineWidth,
                    dash: self.dash ?? []
                ))
                .foregroundStyle(self.lineColor.source(opacity: self.lineOpacity))

                // Horizontal lines
                
                Path { path in
                    
                    guard self.divisions > 1 else { return }
                    
                    for i in 1..<self.divisions {
                        
                        let y = stepHeight * CGFloat(i)
                        path.move(to: CGPoint(x: self.inset, y: y))
                        path.addLine(to: CGPoint(x: size.width - self.inset, y: y))
                        
                    }
                }
                .stroke(style: StrokeStyle(
                    lineWidth: self.lineWidth,
                    dash: self.dash ?? []
                ))
                .foregroundStyle(self.lineColor.source(opacity: self.lineOpacity))
                
                // Optional outer border
                
                if self.showsOuterBorder {
                    
                    Path { path in
                        
                        let rect = CGRect(x: self.inset,
                                          y: self.inset,
                                          width: size.width - self.inset * 2,
                                          height: size.height - self.inset * 2)
                        
                        path.addRect(rect)
                        
                    }
                    .stroke(style: StrokeStyle(
                        lineWidth: self.lineWidth,
                        dash: self.dash ?? []
                    ))
                    .foregroundStyle(self.lineColor.source(opacity: self.lineOpacity))
                    
                }
                
            }
            .animation(.spring, value: self.divisions)
            
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var gridDivision: Int = 3
    
    AppBaseView {
        GridOverlay(divisions: gridDivision)
    }
    .onTapGesture {
        
        var newGridDivision = gridDivision == 5 ? 3 : gridDivision + 1
        gridDivision = newGridDivision
        
    }
    
}
