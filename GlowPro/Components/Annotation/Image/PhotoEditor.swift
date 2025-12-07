import SwiftUI
import Kingfisher
import PencilKit

struct PhotoEditor: UIViewRepresentable {
    
    let imageURL: URL
    let controller: PDFController
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        
        // 1. Assign Delegate to handle zooming/centering
        canvasView.delegate = context.coordinator
        
        canvasView.drawingPolicy = .anyInput
        
        // Configure ScrollView properties
        canvasView.alwaysBounceVertical = true
        canvasView.alwaysBounceHorizontal = true
        canvasView.bouncesZoom = true
        canvasView.showsVerticalScrollIndicator = false
        canvasView.showsHorizontalScrollIndicator = false
        
        // Max zoom allows user to zoom in for detail
        canvasView.maximumZoomScale = 5.0
        
        context.coordinator.canvasView = canvasView
        
        setupControllerLogic(context: context)
        loadImage(into: canvasView, context: context)
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        context.coordinator.updateToolPickerVisibility()
        
        // 2. Recalculate zoom when the SwiftUI view layout changes (e.g., rotation)
        // We wrap this in a check to ensure we have an image to work with
        if context.coordinator.imageView?.image != nil {
             context.coordinator.updateZoomToFit(canvasView: uiView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Controller Logic
    
    private func setupControllerLogic(context: Context) {
        self.controller.captureSnapshot = { [weak coordinator = context.coordinator] in
            return coordinator?.captureSnapshot() ?? Data()
        }
        
        self.controller.toggleDrawing = { [weak coordinator = context.coordinator] isEnabled in
            guard let coordinator = coordinator,
                  let canvasView = coordinator.canvasView else { return }
            
            DispatchQueue.main.async {
                canvasView.drawingPolicy = isEnabled ? .anyInput : .pencilOnly
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
    
    // MARK: - Image Loading
    
    private func loadImage(into canvasView: PKCanvasView, context: Context) {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // Actually irrelevant because we set frame manually
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = false
        
        // Insert at index 0 to be behind drawing
        canvasView.insertSubview(imageView, at: 0)
        context.coordinator.imageView = imageView
        
        imageView.kf.setImage(with: self.imageURL) { result in
            guard case let .success(value) = result else { return }
            
            let image = value.image
            
            DispatchQueue.main.async {
                guard let canvasView = context.coordinator.canvasView else { return }
                
                // Set the "World Size" to the actual image size (e.g., 3000x2000)
                canvasView.contentSize = image.size
                imageView.frame = CGRect(origin: .zero, size: image.size)
                
                // 3. Trigger initial zoom calculation
                context.coordinator.updateZoomToFit(canvasView: canvasView, initialLoad: true)
            }
        }
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, PKCanvasViewDelegate { // Added PKCanvasViewDelegate
        
        var parent: PhotoEditor
        
        private let toolPicker = PKToolPicker()
        var isDrawingEnabled: Bool = true
        
        weak var canvasView: PKCanvasView?
        weak var imageView: UIImageView?
        
        init(_ parent: PhotoEditor) {
            self.parent = parent
            super.init()
        }
        
        // MARK: - Zoom & Layout Logic
        
        func updateZoomToFit(canvasView: PKCanvasView, initialLoad: Bool = false) {
            guard let imageSize = imageView?.image?.size else { return }
            let canvasSize = canvasView.bounds.size
            
            // Avoid dividing by zero if layout hasn't happened yet
            guard canvasSize.width > 0 && canvasSize.height > 0 else { return }
            
            // Calculate scale to fit image completely in view
            let widthScale = canvasSize.width / imageSize.width
            let heightScale = canvasSize.height / imageSize.height
            let minScale = min(widthScale, heightScale)
            
            // Update the minimum zoom scale so the user can't zoom out past the "fit" size
            canvasView.minimumZoomScale = minScale
            
            // If this is the first load, or if the current zoom is invalid, snap to fit.
            if initialLoad || canvasView.zoomScale < minScale {
                canvasView.zoomScale = minScale
            }
            
            // Force a center recalculation
            centerContent(in: canvasView)
        }
        
        // This keeps the image in the center of the screen when zoomed out
        func centerContent(in scrollView: UIScrollView) {
            let boundsSize = scrollView.bounds.size
            var contentsFrame = CGRect(origin: .zero, size: scrollView.contentSize)
            
            if contentsFrame.size.width < boundsSize.width {
                contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
            } else {
                contentsFrame.origin.x = 0.0
            }
            
            if contentsFrame.size.height < boundsSize.height {
                contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
            } else {
                contentsFrame.origin.y = 0.0
            }
            
            // We only need to adjust the imageView if we want to manually move it,
            // but usually modifying the contentInset is cleaner, or simply letting
            // the scrollViewDelegate handle subview positioning.
            // However, PKCanvasView is tricky. The easiest way to center visually
            // is usually via contentInset.
            
            let offsetX = max((boundsSize.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((boundsSize.height - scrollView.contentSize.height) * 0.5, 0)
            
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
        }
        
        // MARK: - PKCanvasViewDelegate / UIScrollViewDelegate
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // Keep content centered while zooming
            centerContent(in: scrollView)
        }
        
        // MARK: - Tool Picker
        
        func updateToolPickerVisibility() {
            guard let canvasView = canvasView, canvasView.window != nil else { return }
            toolPicker.setVisible(isDrawingEnabled, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            if isDrawingEnabled {
                canvasView.becomeFirstResponder()
            } else {
                canvasView.resignFirstResponder()
            }
        }
        
        // MARK: - Snapshot
        
        func captureSnapshot() -> Data {
            guard let canvasView = canvasView,
                  let imageView = imageView,
                  let image = imageView.image else { return Data() }
            
            let imageSize = image.size
            let rect = CGRect(origin: .zero, size: imageSize)
            
            let renderer = UIGraphicsImageRenderer(size: imageSize)
            
            return renderer.image { _ in
                image.draw(in: rect)
                // Draw the PencilKit strokes
                let drawingImage = canvasView.drawing.image(from: rect, scale: 1.0)
                drawingImage.draw(in: rect)
            }.pngData() ?? Data()
        }
    }
}
