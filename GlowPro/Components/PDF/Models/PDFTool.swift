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
    
    case none
    case pen
    case highlighter(alpha: CGFloat = 0.35)
    case scrollAndPan
    case eraser(mode: EraserMode)
    
    var isNoneOrScrollAndPan: Bool {
        switch self {
        case .none, .scrollAndPan: return true
        default: return false
        }
    }
    
}
