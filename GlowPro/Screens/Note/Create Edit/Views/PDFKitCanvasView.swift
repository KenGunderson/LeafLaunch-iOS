//
//  PDFKitCanvasView.swift
//  GlowPro
//
//  Created by Kenneth Gunderson on 10/25/25.
//

import SwiftUI
import PDFKit
import PencilKit

extension Notification.Name {
    
    static let pdfEditorSaveRequest = Notification.Name("pdfEditorSaveRequest")
    static let pdfEditorReplaceDocument = Notification.Name("pdfEditorReplaceDocument")
    static let pdfEditorUndoRequest  = Notification.Name("pdfEditorUndoRequest")
    static let pdfEditorRedoRequest  = Notification.Name("pdfEditorRedoRequest")
    
}

struct PDFKitCanvasView: UIViewRepresentable {
    
    let document: PDFDocument
    let onSaveMergedPDF: (Data) -> Void

    init(document: PDFDocument, onSaveMergedPDF: @escaping (Data) -> Void) {
        
        self.document = document
        self.onSaveMergedPDF = onSaveMergedPDF
        
    }

    @MainActor
    func makeUIView(context: Context) -> ContainerView {
        
        let v = ContainerView()
        v.setup(onSave: onSaveMergedPDF)
        v.setDocument(document)
        return v
        
    }

    @MainActor
    func updateUIView(_ uiView: ContainerView, context: Context) {
        // no-op; live updated via NotificationCenter for doc swaps/saves
    }

    // MARK: - ContainerView

    @MainActor
    final class ContainerView: UIView, PKCanvasViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        
        private let pdfView = PDFView()
        private let canvasView = PKCanvasView()
        private var onSave: ((Data) -> Void)?

        // A separate PKDrawing per PDF page index, so drawings don’t “move” when paging.
        private var pageDrawings: [Int: PKDrawing] = [:]

        private var currentDoc: PDFDocument?
        
        private var initialScaleFactor: CGFloat = 1.0
        
        private var toolPicker: PKToolPicker?
        private weak var attachedWindow: UIWindow?

        // Attach when we have a window
        override func didMoveToWindow() {
            
            super.didMoveToWindow()
            guard let win = self.window, attachedWindow !== win else { return }
            attachedWindow = win
            attachToolPicker()
            ensureToolPickerVisible()
            
        }

        // Detach BEFORE leaving the window (avoids calling from `deinit`)
        override func willMove(toWindow newWindow: UIWindow?) {
            
            super.willMove(toWindow: newWindow)
            if newWindow == nil {
                detachToolPicker()
                NotificationCenter.default.removeObserver(self)
            }
            
        }

        private func attachToolPicker() {
            
            // iOS 14+: create your own picker instance
            let picker = PKToolPicker()
            picker.addObserver(canvasView)
            toolPicker = picker
            
        }

        private func detachToolPicker() {
            
            toolPicker?.removeObserver(canvasView)
            toolPicker = nil
            
        }

        private func ensureToolPickerVisible() {
            
            guard let picker = toolPicker else { return }
            picker.setVisible(true, forFirstResponder: canvasView)
            if !canvasView.isFirstResponder { canvasView.becomeFirstResponder() }
            canvasView.drawingPolicy = .anyInput
            
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        override init(frame: CGRect) {
            
            super.init(frame: frame)
            backgroundColor = .systemBackground

            // PDFView config
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            pdfView.autoScales = true
            pdfView.displayMode = .singlePageContinuous
            pdfView.displayDirection = .vertical
            pdfView.backgroundColor = .secondarySystemBackground
            addSubview(pdfView)

            // PencilKit overlay
            canvasView.translatesAutoresizingMaskIntoConstraints = false
            canvasView.backgroundColor = .clear
            canvasView.isOpaque = false
            canvasView.delegate = self
            canvasView.drawingPolicy = .anyInput
            addSubview(canvasView)

            NSLayoutConstraint.activate([
                pdfView.leadingAnchor.constraint(equalTo: leadingAnchor),
                pdfView.trailingAnchor.constraint(equalTo: trailingAnchor),
                pdfView.topAnchor.constraint(equalTo: topAnchor),
                pdfView.bottomAnchor.constraint(equalTo: bottomAnchor),

                canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
                canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
                canvasView.topAnchor.constraint(equalTo: topAnchor),
                canvasView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

            // Observe save / replace doc / Undo / Redo
            NotificationCenter.default.addObserver(self, selector: #selector(saveRequested), name: .pdfEditorSaveRequest, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(replaceDocument(_:)), name: .pdfEditorReplaceDocument, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(undoRequested), name: .pdfEditorUndoRequest, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(redoRequested), name: .pdfEditorRedoRequest, object: nil)


            // Track page changes to swap drawings
            NotificationCenter.default.addObserver(self, selector: #selector(pageChanged), name: Notification.Name.PDFViewPageChanged, object: pdfView)
            
            
            // PDFView zoom bounds
            pdfView.autoScales = true
            // Once the document is set we’ll also recompute min/max (see setDocument)

            // Allow canvas gestures to coexist (important!)
            canvasView.drawingGestureRecognizer.isEnabled = true
            canvasView.drawingGestureRecognizer.requiresExclusiveTouchType = false

            // Pinch to zoom
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            pinch.delegate = self
            addGestureRecognizer(pinch)

            // Double-tap zoom in
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            doubleTap.delegate = self
            addGestureRecognizer(doubleTap)

            // Two-finger double-tap zoom out (optional)
            let twoFingerDoubleTap = UITapGestureRecognizer(target: self, action: #selector(handleTwoFingerDoubleTap(_:)))
            twoFingerDoubleTap.numberOfTapsRequired = 2
            twoFingerDoubleTap.numberOfTouchesRequired = 2
            twoFingerDoubleTap.delegate = self
            addGestureRecognizer(twoFingerDoubleTap)
            
        }

        required init?(coder: NSCoder) { fatalError() }

        func setup(onSave: @escaping (Data) -> Void) {
            self.onSave = onSave
        }

        // Recompute sensible min/max after a document is loaded
        func setDocument(_ doc: PDFDocument?) {
            currentDoc = doc
            pageDrawings = [:]
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.pdfView.document = doc
                self.pdfView.autoScales = true
                let fit = self.pdfView.scaleFactorForSizeToFit
                self.pdfView.minScaleFactor = fit * 0.5
                self.pdfView.maxScaleFactor = fit * 8.0
                self.pdfView.scaleFactor = fit
                self.loadDrawingForCurrentPage()
                self.ensureToolPickerVisible()   // <- here too
            }
        }

        @objc private func pageChanged() {
            persistCurrentPageDrawing()
            loadDrawingForCurrentPage()
            ensureToolPickerVisible()            // <- keep it visible when the page flips
        }

        private func currentPageIndex() -> Int? {
            
            guard let page = pdfView.currentPage,
                  let idx = pdfView.document?.index(for: page) else { return nil }
            return idx
            
        }

        private func persistCurrentPageDrawing() {
            
            guard let idx = currentPageIndex() else { return }
            pageDrawings[idx] = canvasView.drawing
            
        }

        private func loadDrawingForCurrentPage() {
            
            guard let idx = currentPageIndex() else { canvasView.drawing = PKDrawing(); return }
            canvasView.drawing = pageDrawings[idx] ?? PKDrawing()
            
        }

        // MARK: - Save (merge ink into PDF)

        @objc private func saveRequested() {
            
            persistCurrentPageDrawing()
            guard let doc = currentDoc else { return }

            // Create a new PDF by rendering each page + its drawing overlay
            let newDoc = PDFDocument()

            for pageIndex in 0..<doc.pageCount {
                guard let page = doc.page(at: pageIndex) else { continue }
                let pageBounds = page.bounds(for: .mediaBox)

                // Render the original page into a context
                let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
                let data = renderer.pdfData { ctx in
                    ctx.beginPage()
                    if let cg = page.pageRef {
                        let ctxRef = UIGraphicsGetCurrentContext()!
                        ctxRef.saveGState()
                        ctxRef.translateBy(x: 0, y: pageBounds.height)
                        ctxRef.scaleBy(x: 1, y: -1) // flip
                        ctxRef.drawPDFPage(cg)
                        ctxRef.restoreGState()
                    }

                    // Overlay the drawing for that page (if any), scaled to page space
                    if let drawing = pageDrawings[pageIndex], !drawing.strokes.isEmpty {
                        let image = drawing.image(from: pageBounds, scale: 2.0)
                        image.draw(in: pageBounds)
                    }

                    // Also merge any PDF annotations (like the text we add below)
                    // Those are already part of 'page', so they were drawn with the pageRef above.
                    // If you need live-added annotations beyond the built-in, render them here.
                }

                if let mergedPageDoc = PDFDocument(data: data),
                   let mergedPage = mergedPageDoc.page(at: 0) {
                    newDoc.insert(mergedPage, at: newDoc.pageCount)
                }
            }

            if let data = newDoc.dataRepresentation() {
                onSave?(data)
            }
            
        }

        // MARK: - Swap doc

        @objc private func replaceDocument(_ note: Notification) {
            
            guard let newDoc = note.object as? PDFDocument else { return }
            setDocument(newDoc)
            
        }

        // MARK: - Undo and Redo
        
        @objc private func undoRequested() {
            canvasView.undoManager?.undo()
        }

        @objc private func redoRequested() {
            canvasView.undoManager?.redo()
        }
        
        // MARK: Gesture handlers

        @objc private func handlePinch(_ g: UIPinchGestureRecognizer) {
            guard pdfView.document != nil else { return }
            switch g.state {
            case .began:
                initialScaleFactor = pdfView.scaleFactor
            case .changed, .ended:
                let next = initialScaleFactor * g.scale
                pdfView.scaleFactor = max(pdfView.minScaleFactor, min(next, pdfView.maxScaleFactor))
                if g.state == .ended {
                    ensureToolPickerVisible()   // <- reassert after gesture
                }
            default: break
            }
        }

        @objc private func handleDoubleTap(_ g: UITapGestureRecognizer) {
            let step: CGFloat = 1.25
            pdfView.scaleFactor = min(pdfView.scaleFactor * step, pdfView.maxScaleFactor)
            ensureToolPickerVisible()
        }

        @objc private func handleTwoFingerDoubleTap(_ g: UITapGestureRecognizer) {
            let step: CGFloat = 1.25
            pdfView.scaleFactor = max(pdfView.scaleFactor / step, pdfView.minScaleFactor)
            ensureToolPickerVisible()
        }

        // Allow PDFView + PencilKit + our gestures to work together
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
        
    }
    
}
