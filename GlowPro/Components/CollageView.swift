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
    let action: ((Int) -> Void)?
    
    init(items: [URL?],
         type: CollageType,
         borderColor: ColorSource = Style.shared.background(.border),
         cornerRadius: Theme.RadiusKey = .small,
         height: CGFloat = 400,
         borderLineWidth: CGFloat? = nil,
         action: ((Int) -> Void)? = nil) {
        
        self.items = items
        self.type = type
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.height = height
        self.borderLineWidth = borderLineWidth ?? self.height * 0.016
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
                        let url = self.items[safe: linearIndex] ?? nil
                        
                        image(
                            url: url,
                            maxHeight: maxHeight
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
                        .frame(
                            width: self.height * 0.10,
                            height: self.height * 0.10
                        )
                    
                }
                .frame(height: maxHeight)
                .frame(maxHeight: maxHeight)
            
        }
        
    }
    
    @ViewBuilder
    private func oneLargeTwoSmall() -> some View {
        
        let image1 = self.items[safe: 0] ?? nil
        let image2 = self.items[safe: 1] ?? nil
        let image3 = self.items[safe: 2] ?? nil
        
        VStack(spacing: 0) {
            
            image(
                url: image1,
                maxHeight: CGFloat(self.height / 2)
            )
            .if(self.action != nil) { view in
                
                view.appOnTapGesture {
                    self.action?(0)
                }
                
            }
            
            border(height: self.borderLineWidth)
            
            HStack(spacing: 0) {
               
                image(
                    url: image2,
                    maxHeight: CGFloat(self.height / 2)
                )
                .if(self.action != nil) { view in
                    
                    view.appOnTapGesture {
                        self.action?(1)
                    }
                    
                }
                
                border(width: self.borderLineWidth)
                
                image(
                    url: image3,
                    maxHeight: CGFloat(self.height / 2)
                )
                .if(self.action != nil) { view in
                    
                    view.appOnTapGesture {
                        self.action?(2)
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
    private func oneLargeOneSmall() -> some View {
        
        let image1 = self.items[safe: 0] ?? nil
        let image2 = self.items[safe: 1] ?? nil
        
        VStack(spacing: 0) {
            
            image(
                url: image1,
                maxHeight: CGFloat((self.height) * 2/3)
            )
            .if(self.action != nil) { view in
                
                view.appOnTapGesture {
                    self.action?(0)
                }
                
            }

            border(height: borderLineWidth)

            image(
                url: image2,
                maxHeight: CGFloat((self.height) * 1/3)
            )
            .if(self.action != nil) { view in
                
                view.appOnTapGesture {
                    self.action?(1)
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
    private func oneSmallOneLarge() -> some View {
        
        let image1 = self.items[safe: 0] ?? nil
        let image2 = self.items[safe: 1] ?? nil
        
        VStack(spacing: 0) {
            
            image(
                url: image1,
                maxHeight: CGFloat((self.height) * 1/3)
            )
            .if(self.action != nil) { view in
                
                view.appOnTapGesture {
                    self.action?(0)
                }
                
            }

            border(height: borderLineWidth)

            image(
                url: image2,
                maxHeight: CGFloat((self.height) * 2/3)
            )
            .if(self.action != nil) { view in
                
                view.appOnTapGesture {
                    self.action?(1)
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
    private func twoLargeTwoSmall() -> some View {
        
        let image1 = self.items[safe: 0] ?? nil
        let image2 = self.items[safe: 1] ?? nil
        let image3 = self.items[safe: 2] ?? nil
        let image4 = self.items[safe: 3] ?? nil
        
        VStack(spacing: 0) {
            
            HStack(spacing: 0) {
                
                image(
                    url: image1,
                    maxHeight: CGFloat(self.height / 2)
                )
                .if(self.action != nil) { view in
                    
                    view.appOnTapGesture {
                        self.action?(0)
                    }
                    
                }
                
                border(width: self.borderLineWidth)
                
                image(
                    url: image2,
                    maxHeight: CGFloat(self.height / 2)
                )
                .if(self.action != nil) { view in
                    
                    view.appOnTapGesture {
                        self.action?(1)
                    }
                    
                }
                
            }
            
            border(height: self.borderLineWidth)
            
            HStack(spacing: 0) {
               
                image(
                    url: image3,
                    maxHeight: CGFloat(self.height / 2)
                )
                .if(self.action != nil) { view in
                    
                    view.appOnTapGesture {
                        self.action?(2)
                    }
                    
                }
                
                border(width: self.borderLineWidth)
                
                image(
                    url: image4,
                    maxHeight: CGFloat(self.height / 2)
                )
                .if(self.action != nil) { view in
                    
                    view.appOnTapGesture {
                        self.action?(3)
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
