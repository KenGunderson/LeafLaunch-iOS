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
    
    private let imageURL: URL?
    private let uiImage: UIImage?
    private let canvasSize: CGSize
    private let controller: PDFController
    
    init(url: URL,
         canvasSize: CGSize,
         controller: PDFController) {
        
        self.imageURL = url
        self.uiImage = nil
        self.canvasSize = canvasSize
        self.controller = controller
        
    }
    
    init(image: UIImage,
         canvasSize: CGSize,
         controller: PDFController) {
        
        self.uiImage = image
        self.imageURL = nil
        self.canvasSize = canvasSize
        self.controller = controller
        
    }
        
    func makeUIView(context: Context) -> PKCanvasView {
        
        let canvasView = PKCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        
        canvasView.showsVerticalScrollIndicator = false
        canvasView.showsHorizontalScrollIndicator = false
        canvasView.bouncesZoom = true
        
        canvasView.delegate = context.coordinator
        context.coordinator.canvasView = canvasView
        
        setupControllerLogic(context: context)
        
        loadImage(
            into: canvasView,
            context: context
        )
        
        return canvasView
        
    }
    
    func updateUIView(_ uiView: PKCanvasView,
                      context: Context) {
        
        if context.coordinator.canvasSize != canvasSize {
            
            let oldSize = context.coordinator.canvasSize
            context.coordinator.canvasSize = canvasSize
            
            let isRotation = abs(oldSize.width - canvasSize.height) < 50 && abs(oldSize.height - canvasSize.width) < 50
            
            let shouldForceReset = isRotation || oldSize == .zero
            
            context.coordinator.applyReferenceMath(forceResetZoom: shouldForceReset)
            
        }
        
        context.coordinator.updateToolPickerVisibility()
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
        
    private func loadImage(into canvasView: PKCanvasView,
                           context: Context) {
        
        let imageView = UIImageView()
        context.coordinator.imageView = imageView
        
        if let localImage = self.uiImage {
            
            DispatchQueue.main.async {
                
                self.applyImageToCanvas(
                    localImage,
                    imageView: imageView,
                    canvasView: canvasView,
                    context: context
                )
                
            }
            
            return
            
        }
        
        if let remoteURL = self.imageURL {
            
            imageView.kf.setImage(with: remoteURL) { result in
                
                guard case let .success(value) = result else { return }
                
                DispatchQueue.main.async {
                    
                    self.applyImageToCanvas(
                        value.image,
                        imageView: imageView,
                        canvasView: canvasView,
                        context: context
                    )
                    
                }
                
            }
            
        }
        
    }
    
    private func applyImageToCanvas(_ image: UIImage,
                                    imageView: UIImageView,
                                    canvasView: PKCanvasView,
                                    context: Context) {
        
        if let contentView = canvasView.subviews.first {
            
            contentView.subviews
                .compactMap { $0 as? UIImageView }
                .forEach { $0.removeFromSuperview() }
            
            contentView.insertSubview(imageView, at: 0)
            imageView.image = image
            imageView.frame = CGRect(origin: .zero, size: image.size)
            
            canvasView.contentSize = image.size
            
            context.coordinator.imageSize = image.size
            context.coordinator.canvasSize = self.canvasSize
            
            // Initial load always forces zoom to fit
            context.coordinator.applyReferenceMath(forceResetZoom: true)
            
        }
        
    }
    
    private func setupControllerLogic(context: Context) {
        
        self.controller.captureSnapshot = { [weak coordinator = context.coordinator] in
            return coordinator?.captureSnapshot() ?? Data()
        }
        
        self.controller.toggleDrawing = { [weak coordinator = context.coordinator] isEnabled in
            
            guard let coordinator = coordinator, let canvas = coordinator.canvasView else { return }
            
            DispatchQueue.main.async {
                
                canvas.drawingPolicy = isEnabled ? .anyInput : .pencilOnly
                coordinator.isDrawingEnabled = isEnabled
                coordinator.updateToolPickerVisibility()
                
            }
            
        }
        
        self.controller.performUndo = { [weak coordinator = context.coordinator] in
            coordinator?.canvasView?.undoManager?.undo()
        }
        
        self.controller.performRedo = { [weak coordinator = context.coordinator] in
            coordinator?.canvasView?.undoManager?.redo()
        }
        
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        
        var parent: PhotoEditor
        var isDrawingEnabled: Bool = true
        weak var canvasView: PKCanvasView?
        weak var imageView: UIImageView?
        private let toolPicker = PKToolPicker()
        
        var imageSize: CGSize = .zero
        var canvasSize: CGSize = .zero
        
        init(_ parent: PhotoEditor) {
            self.parent = parent
        }
        
        // FIX 1: Added forceResetZoom parameter
        func applyReferenceMath(forceResetZoom: Bool) {
            
            guard let canvasView = self.canvasView,
                  self.imageSize != .zero,
                  self.canvasSize != .zero else { return }
            
            let widthScale = self.canvasSize.width / self.imageSize.width
            let heightScale = self.canvasSize.height / self.imageSize.height
            
            let fitScale = min(widthScale, heightScale)
            
            canvasView.minimumZoomScale = fitScale
            canvasView.maximumZoomScale = 5.0
            
            if forceResetZoom {
                
                canvasView
                    .setZoomScale(
                        fitScale,
                        animated: false
                    )
                
            } else {
               
                if canvasView.zoomScale < fitScale {
                    canvasView.setZoomScale(fitScale, animated: true)
                }
                
            }
            
            centerContent()
            
        }
        
        func centerContent() {
            
            guard let canvasView = self.canvasView,
                  self.imageSize != .zero else { return }
            
            let boundsSize = canvasView.bounds.size
            let currentScale = canvasView.zoomScale
            
            let contentWidth = self.imageSize.width * currentScale
            let contentHeight = self.imageSize.height * currentScale
            
            let xOffset = max(0, (boundsSize.width - contentWidth) / 2)
            let yOffset = max(0, (boundsSize.height - contentHeight) / 2)
            
            canvasView.contentInset = UIEdgeInsets(
                top: yOffset,
                left: xOffset,
                bottom: 0,
                right: 0
            )
            
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerContent()
        }
        
        func updateToolPickerVisibility() {
            
            guard let canvasView = self.canvasView,
                  canvasView.window != nil else { return }
            
            self.toolPicker
                .setVisible(
                    self.isDrawingEnabled,
                    forFirstResponder: canvasView
                )
            
            self.toolPicker.addObserver(canvasView)
            
            if self.isDrawingEnabled {
                canvasView.becomeFirstResponder()
            } else {
                canvasView.resignFirstResponder()
            }
            
        }
        
        func captureSnapshot() -> Data {
            
            guard let canvasView = self.canvasView,
                  let imageView = self.imageView,
                  let image = imageView.image else { return Data() }
            
            let rect = CGRect(origin: .zero, size: image.size)
            let renderer = UIGraphicsImageRenderer(size: image.size)
            
            return renderer.image { _ in
                image.draw(in: rect)
                canvasView.drawing.image(from: rect, scale: 1.0).draw(in: rect)
            }.pngData() ?? Data()
            
        }
        
    }
    
}
