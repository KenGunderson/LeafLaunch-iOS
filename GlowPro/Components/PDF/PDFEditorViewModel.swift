//
//  PDFEditorViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/28/25.
//

import SwiftUI

public final class PDFEditorViewModel: ObservableObject {
    
    @Published public var currentTool: PDFTool = .pen
    @Published public var strokeColor: Color = .black
    @Published public var strokeWidth: Double = 0.25
    
    @Published public var canUndo: Bool = false
    @Published public var canRedo: Bool = false
    
    @Published public var pageIndex: Int = 0
    @Published public var pageCount: Int = 0
    
    @Published public var toolBeforeGesture: PDFTool?
    
    public init() {}
    
}
