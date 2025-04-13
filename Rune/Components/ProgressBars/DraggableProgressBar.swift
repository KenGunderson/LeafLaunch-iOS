//
//  GestureFillView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/28/24.
//

import SwiftUI

struct DraggableProgressBar: View {
    
    enum Direction {
        
        case vertical
        case horizontal
        
    }
    
    @Binding var currentValue: Int
    var direction: Direction
    var foregroundColor: ColorSource
    var backgroundColor: ColorSource
    var clipShape: AnyShape
    
    init(currentValue: Binding<Int>,
         direction: Direction,
         foregroundColor: ColorSource = Style.shared.accent,
         backgroundColor: ColorSource = Style.shared.background(.quaternary),
         clipShape: AnyShape = .init(.rect(cornerRadius: Style.shared.radius(.small2)))) {
        
        self._currentValue = currentValue
        self.direction = direction
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.clipShape = clipShape
        
    }
    
    var body: some View {
        
        GestureFillView(
            currentValue: self.$currentValue,
            direction: self.direction,
            foregroundColor: self.foregroundColor,
            backgroundColor: self.backgroundColor,
            clipShape: self.clipShape
        )
        
    }
    
}

fileprivate struct GestureFillView: View {
    
    @Binding var currentValue: Int
    @State private var fill: CGFloat = 0
    @State private var container: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    
    var direction: DraggableProgressBar.Direction
    var foregroundColor: ColorSource
    var backgroundColor: ColorSource
    var clipShape: AnyShape
    
    var body: some View {
        
        ZStack(alignment: self.alignment()) {
            
            Rectangle()
                .foregroundStyle(self.backgroundColor.source())
            
            self.fillRectangle
            
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    
                    withAnimation(.linear) {
                        self.updateDrag(with: value)
                    }
                    
                }
                .onEnded { value in
                    self.commitDrag()
                }
        )
        .clipShape(self.clipShape)
        .onGeometryChange(for: CGFloat.self) { geo in
            return self.dimension(from: geo)
        } action: { newValue in
            print(newValue)
            self.container = newValue
        }
        .overlay {
            
            Text("\(self.currentValue)%")
                .font(Style.shared.font(.TITLE_T5))
                .foregroundStyle(Style.shared.textColor(.title).source())
                .contentTransition(.numericText())
            
        }
        
    }
    
    private var fillRectangle: some View {
        
        switch self.direction {
        case .vertical:
            
            return AnyView(Rectangle()
                .frame(height: min(self.container, max(0, self.fill + self.dragOffset)))
                .foregroundStyle(self.foregroundColor.source())
            )
            
        case .horizontal:
            
            return AnyView(Rectangle()
                    .frame(width: min(self.container, max(0, self.fill + self.dragOffset)))
                    .foregroundStyle(self.foregroundColor.source())
            )
            
        }
        
    }
    
    private func alignment() -> Alignment {
        
        switch self.direction {
        case .vertical: return .bottom
        case .horizontal: return .leading
        }
        
    }
    
    private func dimension(from geo: GeometryProxy) -> CGFloat {
        
        switch self.direction {
        case .vertical: return geo.size.height
        case .horizontal: return geo.size.width
        }
        
    }
    
    private func updateDrag(with value: DragGesture.Value) {
        
        switch self.direction {
        case .vertical: self.dragOffset = -value.translation.height * 1.2
        case .horizontal: self.dragOffset = value.translation.width * 1.2
        }
        
        let newFill = min(self.container, max(0, self.fill + self.dragOffset))
        
        if self.container != 0 {
            self.currentValue = Int((newFill / self.container) * 100)
        }
        
    }
    
    private func commitDrag() {
        
        let newFill = min(self.container, max(0, self.fill + self.dragOffset))
        
        self.fill = newFill
        self.dragOffset = 0
        
    }
    
}

#Preview {
    
    @Previewable @State var verticalCurrentValue: Int = 0
    @Previewable @State var horizontalCurrentValue: Int = 0
    
    AppBaseView {
        
        VStack(spacing: 64) {
            
            VStack(alignment: .leading) {
                
                Text("Vertical: \(verticalCurrentValue)")
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .font(.title)
                    .fontWeight(.ultraLight)
                    .fontDesign(.monospaced)
                    .contentTransition(.numericText(value: Double(verticalCurrentValue)))
                
                Text("Horiztonal: \(horizontalCurrentValue)")
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .font(.title)
                    .fontWeight(.ultraLight)
                    .fontDesign(.monospaced)
                    .contentTransition(.numericText(value: Double(horizontalCurrentValue)))
                
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            DraggableProgressBar(
                currentValue: $horizontalCurrentValue,
                direction: .horizontal
            )
            .frame(
                width: 350,
                height: 100
            )
            
            DraggableProgressBar(
                currentValue: $verticalCurrentValue,
                direction: .vertical
            )
            .frame(
                width: 100,
                height: 300
            )
            
        }
        
    }
    
}
