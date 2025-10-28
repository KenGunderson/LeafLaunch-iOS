//
//  PDTool.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/28/25.
//

import Foundation

public enum PDFTool: Equatable {
    
    public enum EraserMode: Equatable {
        
        case lastStroke
        case byHitTest
        
    }
    
    case pen
    case highlighter(alpha: CGFloat = 0.35)
    case eraser(mode: EraserMode)
    
}
