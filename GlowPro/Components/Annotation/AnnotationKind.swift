//
//  AnnotationKind.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/7/25.
//

import UIKit
import PDFKit

enum AnnotationKind {
    
    case image(UIImage)
    case url(URL)
    case pdf(PDFDocument)
    
}
