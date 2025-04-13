//
//  ProgressIndicatorNew.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/10/25.
//


import SwiftUI

struct PageIndicatorView: View {
    
    var selectedIndex: Int = 0
    var numberOfItems: Int = 5
    var selectedColor: ColorSource = Style.shared.accent
    var unselectedColor: ColorSource = Style.shared.background(.quaternary)
    
    func fillColor(isSelected: Bool) -> AnyShapeStyle {
        
        return isSelected
        ? self.selectedColor.source()
        : self.unselectedColor.source()
        
    }
    
    var body: some View {
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            ForEach(0..<numberOfItems, id: \.self) { index in
                
                Capsule()
                    .fill(fillColor(isSelected: selectedIndex == index))
                    .frame(width: selectedIndex == index ? 50 : 8, height: 8)
                
            }
            
        }
        .animation(.snappy, value: self.selectedIndex)
        
    }
    
}

#Preview {
    
    @Previewable @State var selectedIndex: Int = 0
    let numberOfItems = 5
    
    AppBaseView {
        
        PageIndicatorView(
            selectedIndex: selectedIndex,
            numberOfItems: numberOfItems
        )
        
    }
    .appOnTapGesture {
        
        let lastIndex = numberOfItems - 1
        let nextIndex = selectedIndex + 1
        let isLastIndex = selectedIndex == lastIndex
        
        selectedIndex = isLastIndex ? 0 : nextIndex
        
    }
    
}
