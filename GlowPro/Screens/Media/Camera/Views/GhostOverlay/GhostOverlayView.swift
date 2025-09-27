//
//  GhostOverlayView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/31/25.
//

import SwiftUI

struct GhostOverlayView: View {
    
    struct GhostOverlayItem: Equatable {
        
        static func == (lhs: GhostOverlayView.GhostOverlayItem, rhs: GhostOverlayView.GhostOverlayItem) -> Bool {
            
            return lhs.id == rhs.id &&
            lhs.opacity == rhs.opacity &&
            lhs.scale == rhs.scale
            
        }
        
        let id: String
        let image: ImageSource
        var opacity: Double = 0.5
        var scale: CGFloat = 0.5
        
    }
    
    @Binding var selectedGhostOverlayItem: GhostOverlayItem?
    @Binding private var images: [GhostOverlayItem]
    
    @State private var selectedOpacity: Double = 0.5
    @State private var selectedScale: Double = 0.5
    
    init(selectedGhostOverlayItem: Binding<GhostOverlayItem?>,
         images: Binding<[GhostOverlayItem]>) {
        
        self._selectedGhostOverlayItem = selectedGhostOverlayItem
        self._images = images
        
        let initialOpacity = selectedGhostOverlayItem.wrappedValue?.opacity ?? 0.5
        let initialScale = Double(selectedGhostOverlayItem.wrappedValue?.scale ?? 0.5)
        
        self._selectedOpacity = State(initialValue: initialOpacity)
        self._selectedScale = State(initialValue: initialScale)
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if selectedGhostOverlayItem != nil {
                slidersView()
            }
            
            scrollView()
            
        }
        
        // OnChange
        
        .onChange(of: self.selectedGhostOverlayItem) { _, newValue in
            
            // Reset
            
            guard newValue == nil else { return }
            self.selectedOpacity = 0.5
            self.selectedScale = 0.5
            
        }
        .onChange(of: self.selectedScale) { _, newValue in
            
            // Scale
            
            guard var item = self.selectedGhostOverlayItem else { return }
            item.scale = CGFloat(newValue)
            
            if let index = self.images.firstIndex(where: { $0.id == item.id }) {
                self.images[index] = item
            }
            
            self.selectedGhostOverlayItem = item
            
        }
        .onChange(of: self.selectedOpacity) { _, newValue in
            
            // Opacity
            
            guard var item = self.selectedGhostOverlayItem else { return }
            item.opacity = newValue
            
            if let index = self.images.firstIndex(where: { $0.id == item.id }) {
                self.images[index] = item
            }
            
            self.selectedGhostOverlayItem = item
            
        }
        .animation(.smooth, value: self.selectedGhostOverlayItem)
        
    }
    
    private func scrollView() -> some View {
        
        ScrollView(.horizontal) {
            
            HStack(spacing: Style.shared.spacing(.small2)) {
                
                ForEach(self.images, id: \.id) { item in
                    
                    ghostOverlayItem(item)
                        .id(item.id)
                        .transition(.scale.combined(with: .opacity))
                    
                }
                
            }
            
        }
        .animation(.smooth, value: self.images)
        .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
        
    }
    
    private func ghostOverlayItem(_ item: GhostOverlayView.GhostOverlayItem) -> some View {
        
        item
            .image
            .view()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .scaleEffect(item.image.isSystemImage ? 0.9 : 1)
            .appOnTapGesture {
                
                let isAlreadySelected = (self.selectedGhostOverlayItem?.id == item.id)
                var newItem = item
                newItem.opacity = self.selectedOpacity
                newItem.scale = self.selectedScale
                
                self.selectedGhostOverlayItem = isAlreadySelected ? nil : newItem
                
            }
            .padding(8)
            .appBorder(
                cornerRadius: .small2,
                color: (self.selectedGhostOverlayItem?.id == item.id) ? Style.shared.accent : ColorSource.color(.clear),
                lineWidth: 5,
                outerBorder: true
            )
            .background(Style.shared.background(.tertiary).source())
            .cornerRadius(.small2)
            .appShadow(.subtle)
        
    }
    
    private func slidersView() -> some View {
        
        VStack(alignment: .leading, spacing: 2) {
            
            Text("Opacity")
                .appFont(with: .TITLE_2)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            ProgressSlider(value: self.$selectedOpacity, trackStyle: Style.shared.background(.secondary))
                .padding(.horizontal, .small)
                .frame(height: 35)
            
            Text("Scale")
                .appFont(with: .TITLE_2)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .padding(.top, Style.shared.spacing(.custom(2)))
            
            ProgressSlider(value: self.$selectedScale, trackStyle: Style.shared.background(.secondary))
                .padding(.horizontal, .small)
                .frame(height: 35)
            
        }
        .padding(.top, .small)
        .padding(.horizontal, .medium)
        .transition(.opacity)
        
    }
    
}

#Preview {
    
    @Previewable @State var selectedGhostOverlayItem: GhostOverlayView.GhostOverlayItem?
    @Previewable @State var images: [GhostOverlayView.GhostOverlayItem] = [
        .init(id: "1", image: .systemImage("person.fill")),
        .init(id: "2", image: .systemImage("house.fill")),
        .init(id: "3", image: .systemImage("person.2.fill")),
        .init(id: "4", image: .systemImage("circle.fill")),
    ]
    
    ZStack {
        
        Style.shared
            .background(.primary)
            .view()
            .ignoresSafeArea()
        
        GhostOverlayView(
            selectedGhostOverlayItem: $selectedGhostOverlayItem,
            images: (selectedGhostOverlayItem?.id == "2") ? .constant(Array(images.suffix(2))) : $images
        )
        
    }
    
}
