//
//  CollageView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/17/25.
//

import SwiftUI

enum CollageType: Codable,
                  Equatable,
                  Hashable {
    
    case grid(rows: Int, columns: Int)
    case oneLargeTwoSmall
    case oneLargeOneSmall
    case oneSmallOneLarge
    case twoLargeTwoSmall
    
    var rowsAndColumns: (rows: Int, columns: Int) {
        
        switch self {
        case .grid(rows: let rows, columns: let columns): return (rows, columns)
        case .oneLargeTwoSmall: return (1, 2)
        case .oneLargeOneSmall: return (1, 1)
        case .oneSmallOneLarge: return (1, 1)
        case .twoLargeTwoSmall: return (2, 2)
        }
        
    }
    
    var isGrid: Bool {
        
        switch self {
        case .grid: return true
        default: return false
        }
        
    }
    
    var apiName: String {
        
        switch self {
        case .grid: return "GRID"
        case .oneLargeOneSmall: return "ONE_LARGE_ONE_SMALL"
        case .oneLargeTwoSmall: return "ONE_LARGE_TWO_SMALL"
        case .oneSmallOneLarge: return "ONE_SMALL_ONE_LARGE"
        case .twoLargeTwoSmall: return "TWO_LARGE_TWO_SMALL"
        }
        
    }
    
}

struct CollageView: View {
    
    let items: [URL?]
    let type: CollageType
    let borderColor: ColorSource
    let cornerRadius: Theme.RadiusKey
    let height: CGFloat
    let borderLineWidth: CGFloat
    let backgroundColor: ColorSource
    let scaleToFill: Bool
    let action: ((Int) -> Void)?
    
    init(items: [URL?],
         type: CollageType,
         borderColor: ColorSource = Style.shared.background(.border),
         cornerRadius: Theme.RadiusKey = .small,
         height: CGFloat = 400,
         borderLineWidth: CGFloat? = nil,
         backgroundColor: ColorSource = .color(.black),
         scaleToFill: Bool = false,
         action: ((Int) -> Void)? = nil) {
        
        self.items = items
        self.type = type
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.height = height
        self.borderLineWidth = borderLineWidth ?? height * 0.016
        self.backgroundColor = backgroundColor
        self.scaleToFill = scaleToFill
        self.action = action
        
    }
    
    var body: some View {
        
        Group {
            
            switch self.type {
            case .grid: grid()
            case .oneLargeTwoSmall: oneLargeTwoSmall()
            case .oneLargeOneSmall: oneLargeOneSmall()
            case .oneSmallOneLarge: oneSmallOneLarge()
            case .twoLargeTwoSmall: twoLargeTwoSmall()
            }
            
        }
        .background(self.backgroundColor.source())
        .cornerRadius(self.cornerRadius)
        .frame(maxWidth: self.height, maxHeight: self.height)
        .compositingGroup()
        
    }
    
    // MARK: - Image + Border Helpers
    
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
                       size: CGSize) -> some View {
        
        if let url {
            
            ImageSource
                .remote(
                    url: url,
                    placeholder: PlaceholderView().asAnyView()
                )
                .view(renderingMode: .original)
                .aspectRatio(nil, contentMode: self.scaleToFill ? .fill : .fit)
                .frame(width: size.width, height: size.height)
                .frame(maxWidth: size.width, maxHeight: size.height)
                .contentShape(.rect)
                .clipShape(.rect)
            
        } else {
            
            Rectangle()
                .fill(Style.shared.background(.quaternary).source())
                .overlay {
                    ImageSource
                        .systemImage("photo.fill")
                        .view(shouldResize: true, renderingMode: .original)
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: self.height * 0.10,
                            height: self.height * 0.10
                        )
                }
                .frame(width: size.width,
                       height: size.height)
        }
    }
    
    // MARK: - Layouts
    
    @ViewBuilder
    private func grid() -> some View {
        
        let rowsAndColumns = self.type.rowsAndColumns
        
        let safeRows = max(1, rowsAndColumns.rows)
        let safeColumns = max(1, rowsAndColumns.columns)
        
        let totalHorizontalBorderThickness = CGFloat(safeRows - 1) * self.borderLineWidth
        let totalVerticalBorderThickness = CGFloat(safeColumns - 1) * self.borderLineWidth
        
        let cellHeight = (self.height - totalHorizontalBorderThickness) / CGFloat(safeRows)
        let cellWidth  = (self.height - totalVerticalBorderThickness) / CGFloat(safeColumns)
        
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
                        let url = self.items[safe: linearIndex] ?? nil
                        
                        image(
                            url: url,
                            size: .init(width: cellWidth, height: cellHeight)
                        )
                        .if(self.action != nil) { view in
                            
                            view.appOnTapGesture {
                                self.action?(linearIndex)
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        .frame(maxHeight: self.height)
        .appBorder(
            cornerRadius: self.cornerRadius,
            color: self.borderColor,
            lineWidth: 5
        )
        
    }
    
    @ViewBuilder
    private func oneLargeTwoSmall() -> some View {
        
        let imageOne = self.items[safe: 0] ?? nil
        let imageTwo = self.items[safe: 1] ?? nil
        let imageThree = self.items[safe: 2] ?? nil
        
        let fullWidth = self.height
        let halfHeight = self.height / 2
        let halfWidth = (self.height - self.borderLineWidth) / 2
        
        VStack(spacing: 0) {
            
            image(
                url: imageOne,
                size: .init(width: fullWidth, height: halfHeight)
            )
            .if(self.action != nil) { view in
                view.appOnTapGesture { self.action?(0) }
            }
            
            border(height: self.borderLineWidth)
            
            HStack(alignment: .top, spacing: 0) {
                
                image(
                    url: imageTwo,
                    size: .init(width: halfWidth, height: halfHeight)
                )
                .if(self.action != nil) { view in
                    view.appOnTapGesture { self.action?(1) }
                }
                
                border(
                    height: halfHeight,
                    width: self.borderLineWidth
                )
                
                image(
                    url: imageThree,
                    size: .init(width: halfWidth, height: halfHeight)
                )
                .if(self.action != nil) { view in
                    view.appOnTapGesture { self.action?(2) }
                }
                
            }
            
        }
        .frame(maxHeight: self.height)
        .appBorder(
            cornerRadius: self.cornerRadius,
            color: self.borderColor,
            lineWidth: 5
        )
        
    }
    
    @ViewBuilder
    private func oneLargeOneSmall() -> some View {
        
        let imageOne = self.items[safe: 0] ?? nil
        let imageTwo = self.items[safe: 1] ?? nil
        
        let fullWidth = self.height
        let largeHeight = (self.height) * 2 / 3
        let smallHeight = (self.height) * 1 / 3
        
        VStack(spacing: 0) {
            
            image(
                url: imageOne,
                size: .init(width: fullWidth, height: largeHeight)
            )
            .if(self.action != nil) { view in
                view.appOnTapGesture { self.action?(0) }
            }
            
            border(height: self.borderLineWidth)
            
            image(
                url: imageTwo,
                size: .init(width: fullWidth, height: smallHeight)
            )
            .if(self.action != nil) { view in
                view.appOnTapGesture { self.action?(1) }
            }
            
        }
        .frame(maxHeight: self.height)
        .appBorder(
            cornerRadius: self.cornerRadius,
            color: self.borderColor,
            lineWidth: 5
        )
        
    }
    
    @ViewBuilder
    private func oneSmallOneLarge() -> some View {
        
        let imageOne = self.items[safe: 0] ?? nil
        let imageTwo = self.items[safe: 1] ?? nil
        
        let fullWidth = self.height
        let smallHeight = (self.height) * 1 / 3
        let largeHeight = (self.height) * 2 / 3
        
        VStack(spacing: 0) {
            
            image(
                url: imageOne,
                size: .init(width: fullWidth, height: smallHeight)
            )
            .if(self.action != nil) { view in
                view.appOnTapGesture { self.action?(0) }
            }
            
            border(height: self.borderLineWidth)
            
            image(
                url: imageTwo,
                size: .init(width: fullWidth, height: largeHeight)
            )
            .if(self.action != nil) { view in
                view.appOnTapGesture { self.action?(1) }
            }
            
        }
        .frame(maxHeight: self.height)
        .appBorder(
            cornerRadius: self.cornerRadius,
            color: self.borderColor,
            lineWidth: 5
        )
        
    }
    
    @ViewBuilder
    private func twoLargeTwoSmall() -> some View {
        
        let imageOne = self.items[safe: 0] ?? nil
        let imageTwo = self.items[safe: 1] ?? nil
        let imageThree = self.items[safe: 2] ?? nil
        let imageFour = self.items[safe: 3] ?? nil
        
        let halfHeight = self.height / 2
        let halfWidth = (self.height - self.borderLineWidth) / 2
        
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                
                image(
                    url: imageOne,
                    size: .init(width: halfWidth, height: halfHeight)
                )
                .if(self.action != nil) { view in
                    view.appOnTapGesture { self.action?(0) }
                }
                
                border(
                    height: halfHeight,
                    width: self.borderLineWidth
                )
                
                image(
                    url: imageTwo,
                    size: .init(width: halfWidth, height: halfHeight)
                )
                .if(self.action != nil) { view in
                    view.appOnTapGesture { self.action?(1) }
                }
                
            }
            
            border(height: self.borderLineWidth)
            
            HStack(spacing: 0) {
                
                image(
                    url: imageThree,
                    size: .init(width: halfWidth, height: halfHeight)
                )
                .if(self.action != nil) { view in
                    view.appOnTapGesture { self.action?(2) }
                }
                
                border(
                    height: halfHeight,
                    width: self.borderLineWidth
                )
                
                image(
                    url: imageFour,
                    size: .init(width: halfWidth, height: halfHeight)
                )
                .if(self.action != nil) { view in
                    view.appOnTapGesture { self.action?(3) }
                }
                
            }
            
        }
        .frame(maxHeight: self.height)
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
                type: .oneLargeOneSmall,
                cornerRadius: .small
            )
            
            CollageView(
                items: [],
                type: .oneSmallOneLarge,
                cornerRadius: .small
            )
            
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
                cornerRadius: .small,
                height: UIScreen.main.bounds.width - 32
            )
            
            CollageView(
                items: demo.suffix(4),
                type: .twoLargeTwoSmall,
                cornerRadius: .small,
                height: UIScreen.main.bounds.width - 32
            )
            
            CollageView(
                items: Array(demo.prefix(4)),
                type: .grid(rows: 1, columns: 1),
                cornerRadius: .small,
                height: UIScreen.main.bounds.width - 32
            )
            
            CollageView(
                items: Array(demo.prefix(4)),
                type: .grid(rows: 1, columns: 2),
                cornerRadius: .small,
                height: UIScreen.main.bounds.width - 32
            )
            
            CollageView(
                items: Array(demo.prefix(4)),
                type: .grid(rows: 2, columns: 1),
                cornerRadius: .small,
                height: UIScreen.main.bounds.width - 32
            )
            
            CollageView(
                items: Array(demo.prefix(4)),
                type: .grid(rows: 1, columns: 3),
                cornerRadius: .small,
                height: UIScreen.main.bounds.width - 32
            )
            
            CollageView(
                items: Array(demo.prefix(8)),
                type: .grid(rows: 2, columns: 4),
                cornerRadius: .small,
                height: UIScreen.main.bounds.width - 32
            )
            
            CollageView(
                items: Array(demo.prefix(10)),
                type: .grid(rows: 2, columns: 2),
                cornerRadius: .small,
                height: UIScreen.main.bounds.width - 32
            )
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}
