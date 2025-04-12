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
    var selectedFilterColor: ColorSource = Style.shared.accent
    var filterTextColor: ColorSource = Style.shared.textColor(.title)
    var filterSelectedText: ColorSource = Style.shared.textColor(.title)
    var backgroundColor: ColorSource = Style.shared.background(.quaternary)
    var strokeStyle: Bool = false
    var onFilterTapped: (String) -> ()
    var onCloseTapped: () -> ()
    
    @State private var isUserInteractionEnabled: Bool = true
    
    var foregroundStyle: AnyShapeStyle {
        return Style.shared.textColor(.title).source()
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
                            filterTextColor: self.filterTextColor,
                            filterSelectedText: self.filterSelectedText,
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
        .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
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
    let filterTextColor: ColorSource
    let filterSelectedText: ColorSource
    let backgroundColor: ColorSource
    let strokeStyle: Bool
    
    var foregroundStyle: ColorSource {
        return self.isSelected ? self.filterSelectedText : self.filterTextColor
    }
    
    var body: some View {
        EmptyView()

        HStack {
            
            Text(self.title)
                .font(.caption)
                .foregroundStyle(self.foregroundStyle.source())
            
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
    let filterTextColor: ColorSource
    let filterSelectedText: ColorSource
    let backgroundColor: ColorSource
    let strokeStyle: Bool
    
    init(filters: [String],
         selectedFilter: Binding<String?>,
         selectedFilterColor: ColorSource = Style.shared.accent,
         filterTextColor: ColorSource = Style.shared.textColor(.title),
         filterSelectedText: ColorSource = Style.shared.textColor(.title),
         backgroundColor: ColorSource = Style.shared.background(.quaternary),
         strokeStyle: Bool = false) {
        
        self.filters = filters
        self._selectedFilter = selectedFilter
        self.selectedFilterColor = selectedFilterColor
        self.filterTextColor = filterTextColor
        self.filterSelectedText = filterSelectedText
        self.backgroundColor = backgroundColor
        self.strokeStyle = strokeStyle
        
    }
    
    var body: some View {
        
        AppBaseView {
            
            FiltersView(
                filters: self.filters,
                selectedFilter: self.selectedFilter,
                selectedFilterColor: self.selectedFilterColor,
                filterTextColor: self.filterTextColor,
                filterSelectedText: self.filterSelectedText,
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
