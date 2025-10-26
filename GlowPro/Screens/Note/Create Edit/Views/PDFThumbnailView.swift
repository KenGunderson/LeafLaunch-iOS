//
//  PDFThumbnailView.swift
//  GlowPro
//
//  Created by Kenneth Gunderson on 10/25/25.
//

import SwiftUI
import PDFKit

struct PDFThumbnailView: View {
    
    let url: URL
    var size: CGSize = CGSize(width: 140, height: 180)

    @State private var image: UIImage?
    @State private var failed = false

    var body: some View {
        
        ZStack {
            
            if let img = image {
                
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
            }
            
        }
        .frame(width: size.width, height: size.height)
        .task {
            await loadThumbnail()
        }
        
    }

    @MainActor
    private func loadThumbnail() async {
        
        guard !failed, image == nil else { return }

        // Create the document once, not in `body`
        guard let doc = PDFDocument(url: url),
              let page = doc.page(at: 0) else {
            failed = true
            return
        }

        // Use a safe display box. `.artBox` is often empty → bad bounds.
        let thumb = page.thumbnail(of: size, for: .cropBox) // or .mediaBox
        self.image = thumb
        
    }
    
}
