//
//  PDFCommand.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/28/25.
//

import PDFKit

public enum PDFExportMode: Equatable {
    case originalWithAnnotations
}

public enum PDFCommand: Equatable {
    
    case save
    case undo
    case redo
    
    case setTool(PDFTool)
    case setStroke(color: UIColor)
    case setWidth(CGFloat)
    
    case replaceDocument(PDFDocument)
    case jumpToPage(Int)
    case clearCurrentPage
    
    case export(mode: PDFExportMode)
        
}
