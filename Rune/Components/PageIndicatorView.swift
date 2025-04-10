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
    var selectedColor: ColorSource = .color(ThemeManager.shared.accentColor())
    var unselectedColor: ColorSource = .color(ThemeManager.shared.background(.quad))
    
    func fillColor(isSelected: Bool) -> AnyShapeStyle {
        
        return isSelected
        ? self.selectedColor.source()
        : self.unselectedColor.source()
        
    }
    
    var body: some View {
        
        HStack(spacing: Spacing.small.value) {
            
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
    var numberOfItems = 5
    
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
