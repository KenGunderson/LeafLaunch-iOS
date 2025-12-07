//
//  PhotoEditor.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/7/25.
//

import SwiftUI
import Kingfisher
import PencilKit

struct PhotoEditor: UIViewRepresentable {
    
    let imageURL: URL
    let controller: PDFController
    
    func makeUIView(context: Context) -> PKCanvasView {
        
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = true
        
        canvasView.minimumZoomScale = 1.0
        canvasView.maximumZoomScale = 5.0
        canvasView.delegate = context.coordinator
        canvasView.showsVerticalScrollIndicator = false
        canvasView.showsHorizontalScrollIndicator = false
        
        // MARK: - Image View
        
        let imageView = UIImageView()
        imageView.kf.setImage(with: self.imageURL)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        canvasView.addSubview(imageView)
        canvasView.sendSubviewToBack(imageView)
        
        // IMPORTANT:
        // PKCanvasView is a UIScrollView, so use its frameLayoutGuide
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: canvasView.frameLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: canvasView.frameLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: canvasView.frameLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: canvasView.frameLayoutGuide.bottomAnchor)
        ])
        
        // Don’t manually set frame or contentSize or zoomScale here.
        // Let Auto Layout size it to the visible rect, and aspectFit will keep it centered.
        
        setupController(
            canvasView,
            imageView: imageView,
            context: context
        )
        
        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView,
                      context: Context) {
        
        // Handle updates if specific state changes (rare for just drawing)
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Controller Wiring
    
    private func setupController(_ canvasView: PKCanvasView,
                                 imageView: UIImageView, context: Context) {
        
        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        
        self.controller.captureSnapshot = { [weak canvasView, weak imageView] in
            
            guard let canvasView,
                  let imageView else { return Data() }
            
            canvasView.layoutIfNeeded()
            
            let size = canvasView.bounds.size
            
            guard size.width > 0, size.height > 0 else {
                
                assertionFailure("Canvas size is zero when capturing snapshot")
                return Data()
                
            }
            
            let renderer = UIGraphicsImageRenderer(size: size)
            
            let image = renderer.image { ctx in
                
                let rect = CGRect(origin: .zero, size: size)
                imageView.draw(rect)
                
                let drawingImage = canvasView.drawing.image(from: rect, scale: 1)
                drawingImage.draw(in: rect)
                
            }
            
            return image.pngData() ?? Data()
            
        }
        
        self.controller.toggleDrawing = { isEnabled in
            
            canvasView.drawingPolicy = isEnabled ? .anyInput : .pencilOnly
            toolPicker.setVisible(isEnabled, forFirstResponder: canvasView)
            
        }
        
        self.controller.performUndo = {
            canvasView.undoManager?.undo()
        }
        
        self.controller.performRedo = {
            canvasView.undoManager?.redo()
        }

    }

    // MARK: - Coordinator
    class Coordinator: NSObject, PKCanvasViewDelegate {
        
        var parent: PhotoEditor
        
        init(_ parent: PhotoEditor) {
            self.parent = parent
        }
        
        // This ensures the Image zooms WITH the drawings
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first(where: { $0 is UIImageView })
        }
        
    }
    
}
