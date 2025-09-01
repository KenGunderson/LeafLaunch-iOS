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
    @State private var selectedOpacity: Double = 0.5
    @State private var selectedScale: Double = 0.5
    
    @State private var images: [GhostOverlayItem] = [
        .init(id: "1", image: .image(.appIcon)),
        .init(id: "2", image: .systemImage("person.fill"))
    ]
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            title()
            
            scrollView()
            
            if selectedGhostOverlayItem != nil {
                slidersView()
            }
            
        }
        .padding(.top, .large)
        
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
    
    private func title() -> some View {
        
        Text("Select Ghost Overlay:")
            .appFont(with: .TITLE_5)
            .foregroundStyle(Style.shared.textColor(.title).source())
            .padding(.leading, .medium)
        
    }
    
    private func scrollView() -> some View {
        
        ScrollView(.horizontal) {
            
            HStack(spacing: Style.shared.spacing(.medium)) {
                
                ForEach(self.images, id: \.id) { image in
                    
                    image
                        .image
                        .view()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .scaleEffect(image.image.isSystemImage ? 0.9 : 1)
                        .appOnTapGesture {
                            
                            let isAlreadySelected = (self.selectedGhostOverlayItem?.id == image.id)
                            var newItem = image
                            newItem.opacity = self.selectedOpacity
                            newItem.scale = self.selectedScale
                            
                            self.selectedGhostOverlayItem = isAlreadySelected ? nil : newItem
                            
                        }
                        .appBorder(
                            cornerRadius: .small,
                            color: .color(self.selectedGhostOverlayItem?.id == image.id ? .white : .clear),
                            lineWidth: 5,
                            outerBorder: true
                        )
                        .cornerRadius(.small)
                    
                }
                
            }
            
        }
        .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
        
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
        .transition(.move(edge: .bottom).combined(with: .opacity))
        
    }
    
}
