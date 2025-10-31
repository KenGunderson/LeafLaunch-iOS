//
//  MediaFusion.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/16/25.
//

import _PhotosUI_SwiftUI
import PDFKit


struct MediaFusion: Equatable {
    
    static func == (lhs: MediaFusion, rhs: MediaFusion) -> Bool {
        lhs.id == rhs.id
    }

    enum Kind {
        
        case uiImage(UIImage)
        case pdf(Data)
        case url(URL)
        
        var image: UIImage? {
            
            switch self {
            case .uiImage(let image): return image
            case .pdf: return getImageFromPDF()
            case .url: return nil
            }
            
        }
        
        var url: URL? {
            
            switch self {
            case .uiImage: return nil
            case .pdf: return nil
            case .url(let url): return url
            }
            
        }
        
        var data: Data? {
            
            switch self {
            case .uiImage: return nil
            case .pdf(let data): return data
            case .url: return nil
            }
            
        }
        
        var isPDF: Bool {
            
            switch self {
            case .pdf: return true
            case .uiImage: return false
            case .url: return false
            }
            
        }
        
        func getImageFromPDF() -> UIImage? {
            
            guard let data = self.data, let document = PDFDocument(data: data),
                  let page = document.page(at: 0) else { return nil }
            
            // TODO: - Handle Width / Height with Page Rect
            let pdfImage = page.thumbnail(of: .init(
                width: 1080, height: 1080
            ), for: .cropBox
            )
            
            return pdfImage
            
        }
        
    }
    
    let id: String
    let kind: Kind
    let isUploaded: Bool
    let media: Media?
    
    init(id: String = UUID().uuidString,
         kind: Kind,
         isUploaded: Bool,
         media: Media? = nil) {
        
        self.id = id
        self.kind = kind
        self.isUploaded = isUploaded
        self.media = media
        
    }
    
}
