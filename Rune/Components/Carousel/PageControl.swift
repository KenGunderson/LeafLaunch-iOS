//
//  PageControl.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 10/30/24.
//

import SwiftUI

struct PageControl: View {
    
    @Namespace private var animation
    
    let totalIndex: Int
    let selectedIndex: Int
    let unhighlightColor: ColorSource
    let highlightColor: ColorSource
    let height: CGFloat
    
    init(totalIndex: Int,
         selectedIndex: Int,
         unhighlightColor: ColorSource = .material(.ultraThinMaterial),
         highlightColor: ColorSource = Style.shared.background(.quaternary),
         height: CGFloat = 8) {
        
        self.totalIndex = totalIndex
        self.selectedIndex = selectedIndex
        self.unhighlightColor = unhighlightColor
        self.highlightColor = highlightColor
        self.height = height

    }
    
    var body: some View {
        
        HStack {
            
            ForEach(0..<totalIndex, id: \.self) { index in
                pageIndicator(for: index)
            }
            
        }
        .animation(
            .bouncy,
            value: UUID()
        )
        
    }
    
    @ViewBuilder
    private func pageIndicator(for index: Int) -> some View {
        
        Circle()
            .fill(self.unhighlightColor.source())
            .frame(height: self.height)
            .overlay {
                
                if selectedIndex == index {
                    
                    selectedIndicator
                        .matchedGeometryEffect(
                            id: "IndicatorAnimationId",
                            in: animation
                        )
                    
                }
                
            }
        
    }
    
    private var selectedIndicator: some View {
        
        Circle()
            .fill(self.highlightColor.source())
            .frame(height: self.height)
        
    }
    
}

#Preview {
    
    PageControl(
        totalIndex: 5,
        selectedIndex: 1,
        highlightColor: .color(.blue),
        height: 32
    )
    
}
