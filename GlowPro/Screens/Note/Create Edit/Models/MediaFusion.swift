//
//  MediaFusion.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/16/25.
//

import _PhotosUI_SwiftUI

struct MediaFusion: Equatable {
    
    static func == (lhs: MediaFusion, rhs: MediaFusion) -> Bool {
        lhs.id == rhs.id
    }

    enum Kind {
        
        case uiImage(UIImage)
        case url(URL)
        
        var url: URL? {
            
            switch self {
            case .uiImage: return nil
            case .url(let url): return url
            }
            
        }
        
    }
    
    let id: String
    let kind: Kind
    let isUploaded: Bool
    
    init(id: String = UUID().uuidString,
         kind: Kind,
         isUploaded: Bool) {
        
        self.id = id
        self.kind = kind
        self.isUploaded = isUploaded
        
    }
    
}
