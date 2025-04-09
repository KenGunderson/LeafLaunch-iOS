//
//  FiltersView.swift
//  Rune
//
//  Created by Sako Hovaguimian on 4/9/25.
//


import SwiftUI

struct FiltersView: View {
    
    var filters: [String]
    var selectedFilter: String? = nil
    var selectedFilterColor: ColorSource = .color(ThemeManager.shared.accentColor())
    var backgroundColor: ColorSource = .color(ThemeManager.shared.background(.quad))
    var strokeStyle: Bool = false
    var onFilterTapped: (String) -> ()
    var onCloseTapped: () -> ()
    
    @State private var isUserInteractionEnabled: Bool = true
    
    var foregroundStyle: Color {
        return ThemeManager.shared.textColor(.title)
    }
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            HStack {
                
                if self.selectedFilter != nil {
                    
                    Image(systemName: "xmark")
                        .padding(6)
                        .background {
                            Circle()
                                .stroke(self.foregroundStyle.opacity(0.5))
                        }
                        .foregroundStyle(self.foregroundStyle.opacity(0.5))
                        .transition(AnyTransition(.move(edge: .leading)).combined(with: .opacity))
                        .appOnTapGesture {
                            
                            withAnimation(.smooth) {
                                onCloseTapped()
                            }
                            
                        }
                    
                }
                
                ForEach(self.filters, id: \.self) { filter in
                    
                    if self.selectedFilter == nil || self.selectedFilter == filter {
                        
                        FilterView(
                            title: filter,
                            isSelected: selectedFilter == filter,
                            selectedColor: self.selectedFilterColor,
                            backgroundColor: self.backgroundColor,
                            strokeStyle: self.strokeStyle
                        )
                        .appOnTapGesture {
                            
                            throttleTouch()
                            onFilterTapped(filter)
                            
                        }
                        .transition(
                            .opacity
                            .combined(with: .scale)
                            .combined(with: .blurReplace)
                            .combined(with: .move(edge: .leading))
                        )
                        
                    }
                    
                }
                
            }
            .allowsHitTesting(self.isUserInteractionEnabled)
            .animation(.smooth(duration: 0.5), value: selectedFilter)
            
        }
        .safeAreaPadding(.horizontal, Spacing.medium.value)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func throttleTouch() {
        
        self.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            self.isUserInteractionEnabled = true
        })
        
    }

}

internal struct FilterView: View {
    
    let title: String
    let isSelected: Bool
    let selectedColor: ColorSource
    let backgroundColor: ColorSource
    let strokeStyle: Bool
    
    var foregroundStyle: Color {
        return ThemeManager.shared.textColor(.title)
    }
    
    var body: some View {
        EmptyView()

        HStack {
            
            Text(self.title)
                .font(.caption)
                .foregroundStyle(foregroundStyle)
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background {
            
            ZStack {
                
                let backgroundColor = self.isSelected 
                    ? self.selectedColor
                    : self.backgroundColor
                
                Capsule(style: .circular)
                    .fill(self.strokeStyle ? backgroundColor.source().opacity(1) : backgroundColor.source().opacity(0.8))
                    .opacity(self.strokeStyle && !self.isSelected ? 0 : 1)
                
                if self.strokeStyle {
                    
                    Capsule(style: .circular)
                        .strokeBorder(self.isSelected ? backgroundColor.source().opacity(1) : backgroundColor.source().opacity(0.3), lineWidth: 1)
                    
                }

            }
            
        }
        
    }
    
}

internal struct FiltersViewPreview: View {
    
    @Binding var selectedFilter: String?
    
    var filters: [String] = []
    let selectedFilterColor: ColorSource
    let backgroundColor: ColorSource
    let strokeStyle: Bool
    
    init(filters: [String],
         selectedFilter: Binding<String?>,
         selectedFilterColor: ColorSource = .color(ThemeManager.shared.accentColor()),
         backgroundColor: ColorSource = .color(ThemeManager.shared.background(.quad)),
         strokeStyle: Bool = false) {
        
        self.filters = filters
        self._selectedFilter = selectedFilter
        self.selectedFilterColor = selectedFilterColor
        self.backgroundColor = backgroundColor
        self.strokeStyle = strokeStyle
        
    }
    
    var body: some View {
        
        AppBaseView {
            
            FiltersView(
                filters: self.filters,
                selectedFilter: self.selectedFilter,
                selectedFilterColor: self.selectedFilterColor,
                backgroundColor: self.backgroundColor,
                strokeStyle: self.strokeStyle) { filter in
                    
                    self.selectedFilter = filter
                    
                } onCloseTapped: {
                    
                    self.selectedFilter = nil
                    
                }
            
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var selectedFilter: String?
    
    FiltersViewPreview(
        filters: ["Sako", "Mitch", "KC", "Michael"],
        selectedFilter: $selectedFilter,
        strokeStyle: true
    )
    
}

#Preview {
    
    @Previewable @State var selectedFilter: String?
    
    FiltersViewPreview(
        filters: ["Sako", "Mitch", "KC", "Michael"],
        selectedFilter: $selectedFilter,
        strokeStyle: false
    )
    
}
