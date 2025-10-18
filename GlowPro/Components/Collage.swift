//
//  Collage.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/17/25.
//

// TODO: -
/// Remaining grid sizes

import SwiftUI

enum CollageType {
    
    case grid(rows: Int, columns: Int)
    case oneLargeTwoSmall
    case twoLargeTwoSmall
    
    var rowsAndColumns: (rows: Int, columns: Int) {
        
        switch self {
        case .grid(rows: let rows, columns: let columns):
            return (rows, columns)
        case .oneLargeTwoSmall:
            return (1, 2)
        case .twoLargeTwoSmall:
            return (2, 2)
        }
        
    }
    
}

struct CollageView: View {
    
    let items: [URL]
    let type: CollageType
    let borderColor: ColorSource
    let cornerRadius: Theme.RadiusKey
    let height: Int
    let borderLineWidth: CGFloat = 5
    
    init(items: [URL],
         type: CollageType,
         borderColor: ColorSource = Style.shared.background(.border),
         cornerRadius: Theme.RadiusKey,
         height: Int = 400) {
        
        self.items = items
        self.type = type
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.height = height
        
    }
    
    var body: some View {
        
        Group {
            switch self.type {
            case .grid: grid()
            case .oneLargeTwoSmall: oneLargeTwoSmall()
            case .twoLargeTwoSmall: twoLargeTwoSmall()
            }
        }
        .background(self.borderColor.source())
        .cornerRadius(self.cornerRadius)
        
    }
    
    @ViewBuilder
    private func grid() -> some View {
        
        let rowsAndColumns = self.type.rowsAndColumns
        
        let safeRows = max(1, rowsAndColumns.rows)
        let safeColumns = max(1, rowsAndColumns.columns)
        let maxHeight = CGFloat(self.height) / CGFloat(safeRows)
                
        VStack(spacing: 0) {
            
            ForEach(0..<safeRows, id: \.self) { rowIndex in
                
                if rowIndex != 0 {
                    border(height: self.borderLineWidth)
                }
                
                HStack(spacing: 0) {
                    
                    ForEach(0..<safeColumns, id: \.self) { columnIndex in
                        
                        if columnIndex != 0 {
                            border(width: self.borderLineWidth)
                        }
                        
                        let linearIndex = (rowIndex * safeColumns) + columnIndex
                        let url = self.items[safe: linearIndex]
                        
                        image(
                            url: url,
                            maxHeight: maxHeight
                        )
                        
                    }
                    
                }
                
            }
            
        }
        .frame(maxHeight: CGFloat(self.height))
        .appBorder(
            cornerRadius: self.cornerRadius,
            color: self.borderColor,
            lineWidth: 5
        )
        
    }
    
    @ViewBuilder
    private func border(height: CGFloat? = nil,
                        width: CGFloat? = nil) -> some View {
        
        Rectangle()
            .fill(self.borderColor.source())
            .frame(
                width: width,
                height: height
            )
        
    }
    
    @ViewBuilder
    private func image(url: URL?,
                       maxHeight: CGFloat) -> some View {
        
        if let url {
            
            ImageSource
                .remote(
                    url: url,
                    placeholder: PlaceholderView().asAnyView()
                )
                .view(renderingMode: .original)
                .frame(height: maxHeight)
                .frame(maxHeight: maxHeight)
//                .scaledToFill()
                .contentShape(.rect)
                .clipShape(.rect)
            
        } else {
            
            Rectangle()
                .fill(Style.shared.background(.quaternary).source())
                .overlay {
                    
                    Image(systemName: "photo.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                    
                }
                .frame(height: maxHeight)
                .frame(maxHeight: maxHeight)
            
        }
        
    }
    
    @ViewBuilder
    private func oneLargeTwoSmall() -> some View {
        
        let image1 = self.items[safe: 0]
        let image2 = self.items[safe: 1]
        let image3 = self.items[safe: 2]
        
        VStack(spacing: 0) {
            
            image(
                url: image1,
                maxHeight: CGFloat(self.height / 2)
            )
            
            border(height: self.borderLineWidth)
            
            HStack(spacing: 0) {
               
                image(
                    url: image2,
                    maxHeight: CGFloat(self.height / 2)
                )
                
                border(width: self.borderLineWidth)
                
                image(
                    url: image3,
                    maxHeight: CGFloat(self.height / 2)
                )
                
                
            }
            
        }
        .frame(maxHeight: CGFloat(self.height))
        .appBorder(
            cornerRadius: self.cornerRadius,
            color: self.borderColor,
            lineWidth: 5
        )
        
    }
    
    @ViewBuilder
    private func twoLargeTwoSmall() -> some View {
        
        let image1 = self.items[safe: 0]
        let image2 = self.items[safe: 1]
        let image3 = self.items[safe: 2]
        let image4 = self.items[safe: 3]
        
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                
                image(
                    url: image1,
                    maxHeight: CGFloat(self.height / 2)
                )
                
                border(width: self.borderLineWidth)
                
                image(
                    url: image2,
                    maxHeight: CGFloat(self.height / 2)
                )
                
            }
            
            border(height: self.borderLineWidth)
            
            HStack(spacing: 0) {
               
                image(
                    url: image3,
                    maxHeight: CGFloat(self.height / 2)
                )
                
                border(width: self.borderLineWidth)
                
                image(
                    url: image4,
                    maxHeight: CGFloat(self.height / 2)
                )
                
                
            }
            
        }
        .frame(maxHeight: CGFloat(self.height))
        .appBorder(
            cornerRadius: self.cornerRadius,
            color: self.borderColor,
            lineWidth: 5
        )
        
    }
    
}

#Preview("Template") {
    
    let demo = (1...16).compactMap { URL(string: "https://picsum.photos/id/\($0)/604/1001") }
    
    ScrollView {
        
        VStack(spacing: 32) {
            
            CollageView(
                items: [],
                type: .oneLargeTwoSmall,
                cornerRadius: .small
            )
            
            CollageView(
                items: [],
                type: .twoLargeTwoSmall,
                cornerRadius: .small
            )
            
            CollageView(
                items: [],
                type: .grid(rows: 1, columns: 1),
                cornerRadius: .small
            )
            
            CollageView(
                items: [],
                type: .grid(rows: 1, columns: 2),
                cornerRadius: .small
            )
            
            CollageView(
                items: [],
                type: .grid(rows: 1, columns: 3),
                cornerRadius: .small
            )
            
            CollageView(
                items: [],
                type: .grid(rows: 2, columns: 2),
                cornerRadius: .small
            )
            
            CollageView(
                items: [],
                type: .grid(rows: 4, columns: 2),
                cornerRadius: .small
            )
            
        }
        .padding(.horizontal, .large)
        
    }
    
}

#Preview {
    
    let demo = (1...16).compactMap { URL(string: "https://picsum.photos/id/\($0)/604/1001") }
    
    ScrollView {
        
        VStack(spacing: 32) {
            
            CollageView(
                items: demo.suffix(3),
                type: .oneLargeTwoSmall,
                cornerRadius: .small
            )
            
            CollageView(
                items: demo.suffix(4),
                type: .twoLargeTwoSmall,
                cornerRadius: .small
            )
            
            CollageView(
                items: Array(demo.prefix(4)),
                type: .grid(rows: 1, columns: 1),
                cornerRadius: .small
            )
            
            CollageView(
                items: Array(demo.prefix(4)),
                type: .grid(rows: 1, columns: 2),
                cornerRadius: .small
            )
            
            CollageView(
                items: Array(demo.prefix(4)),
                type: .grid(rows: 2, columns: 1),
                cornerRadius: .small
            )
            
            CollageView(
                items: Array(demo.prefix(4)),
                type: .grid(rows: 1, columns: 3),
                cornerRadius: .small
            )
            
            CollageView(
                items: Array(demo.prefix(8)),
                type: .grid(rows: 2, columns: 4),
                cornerRadius: .small
            )
            
            CollageView(
                items: Array(demo.prefix(10)),
                type: .grid(rows: 2, columns: 2),
                cornerRadius: .small
            )
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}
