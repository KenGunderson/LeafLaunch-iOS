//
//  PDFAction.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/28/25.
//

import UIKit

public enum PDFAction: Equatable {
    
    case didSave(data: Data)
    case undoAvailability(canUndo: Bool, canRedo: Bool)
    case didChangeTool(PDFTool)
    case didChangeStroke(color: UIColor, width: CGFloat)
    case didJumpToPage(index: Int, count: Int)
    case error(message: String)
    
}
