//
//  GhostOverlayCarouselView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/19/25.
//

import SwiftUI

struct GhostOverlayCarouselView: View {
    
    @Binding private var selectedGhostOverlayCategory: GhostOverlayCategory?
    @Namespace private var selectedCategory
    
    init(selectedGhostOverlayCategory: Binding<GhostOverlayCategory?>) {
        self._selectedGhostOverlayCategory = selectedGhostOverlayCategory
    }
    
    var body: some View {
        
        ScrollViewReader { proxy in
            
            ScrollView(.horizontal) {
                
                HStack(spacing: Style.shared.spacing(.medium2)) {
                    
                    ForEach(GhostOverlayCategory.allCases, id: \.self) { category in
                        
                        let isSelected = (self.selectedGhostOverlayCategory == category)
                        
                        cateogry(
                            category,
                            isSelected: isSelected
                        )
                        
                    }
                    
                }
                
            }
//            .contentMargins([.leading], (UIScreen.main.bounds.width / 2) - 24)
//            .contentMargins([.trailing], (UIScreen.main.bounds.width / 2) - 36)
            .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
            .scrollIndicators(.hidden)
            .onChange(of: self.selectedGhostOverlayCategory) { oldValue, newValue in
                
                withAnimation(.smooth) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
                
            }
            .animation(.smooth, value: self.selectedGhostOverlayCategory)
            
        }
        
    }
    
    private func cateogry(_ category: GhostOverlayCategory,
                          isSelected: Bool) -> some View {
        
        let accentColor = Style.shared.accent.source()
        
        return Text(category.displayName)
            .appFont(with: .HEADER_1)
            .foregroundStyle(isSelected ? accentColor : Style.shared.textColor(.title).source())
            .padding(.bottom, 12)
            .overlay(alignment: .bottom) {
                
                Capsule()
                    .fill(.clear)
                    .frame(height: 6)
                
                if isSelected {
                    
                    Capsule()
                        .fill(accentColor)
                        .frame(height: 6)
                        .matchedGeometryEffect(id: "ACTIVE_TAB", in: self.selectedCategory)
                    
                }
                
            }
            .onTapGesture {
                self.selectedGhostOverlayCategory = category
            }
            .tag(category)
            .id(category)
        
    }
    
}

#Preview {

    @Previewable @State var ghostOverlayCategory: GhostOverlayCategory? = .face
    
    GhostOverlayCarouselView(
        selectedGhostOverlayCategory: $ghostOverlayCategory
    )
    
}
