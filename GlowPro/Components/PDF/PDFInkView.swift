//
//  PDFInkView.swift
//  GlowPro
//
//  Created by Kenneth Gunderson on 10/25/25.
//

import SwiftUI
import PDFKit

extension Notification.Name {
    
    static let pdfEditorSaveRequest = Notification.Name("pdfEditorSaveRequest")
    static let pdfEditorReplaceDocument = Notification.Name("pdfEditorReplaceDocument")
    static let pdfEditorUndoRequest = Notification.Name("pdfEditorUndoRequest")
    static let pdfEditorRedoRequest = Notification.Name("pdfEditorRedoRequest")
    static let pdfEditorColorChanged = Notification.Name("pdfEditorColorChanged")
    static let pdfEditorWidthChanged = Notification.Name("pdfEditorWidthChanged")
    
}

struct PDFInkView: UIViewRepresentable {
    
    let document: PDFDocument
    let onSave: (Data) -> Void

    func makeUIView(context: Context) -> InkContainer {
        
        let v = InkContainer()
        v.configure(document: document, onSave: onSave)
        
        return v
        
    }

    func updateUIView(_ uiView: InkContainer, context: Context) {}
    
}

@MainActor
final class InkContainer: UIView, UIGestureRecognizerDelegate {
    
    private let pdfView = PDFView()
    private var onSave: ((Data) -> Void)?

    // Drawing state
    private var currentPage: PDFPage?
    private var currentPath = UIBezierPath()
    private var currentPoints: [CGPoint] = []
    private var strokeColor: UIColor = .black
    private var strokeWidth: Double = 2.5
    
    private var liveLayer = CAShapeLayer()
    private var pathViewSpace = UIBezierPath()
    private var pathPageSpace = UIBezierPath()

    // Undo/redo stacks per page index
    private var undoStacks: [Int: [PDFAnnotation]] = [:]
    private var redoStacks: [Int: [PDFAnnotation]] = [:]

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupSubviews()
        
    }
    
    private var pdfScrollView: UIScrollView? {
        return pdfView.subviews.compactMap { $0 as? UIScrollView }.first
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(document: PDFDocument, onSave: @escaping (Data) -> Void) {
        
        self.onSave = onSave
        self.pdfView.document = document
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            
            let fit = self.pdfView.scaleFactorForSizeToFit
            self.pdfView.minScaleFactor = fit * 1.0
            self.pdfView.maxScaleFactor = fit * 8.0
            self.pdfView.scaleFactor = fit
            
        }
        
    }
    
    // MARK: - Subviews
    
    private func setupSubviews() {
        
        // PDF VIEW
        self.pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.pdfView.autoScales = true
        self.pdfView.displayMode = .singlePageContinuous
        self.pdfView.displayDirection = .vertical
        self.pdfView.displaysPageBreaks = true
        self.pdfView.displayBox = .cropBox
        self.pdfView.backgroundColor = .clear

        // LIVE LAYER
        self.liveLayer.strokeColor = self.strokeColor.cgColor
        self.liveLayer.fillColor = UIColor.clear.cgColor
        self.liveLayer.lineWidth = self.strokeWidth
        self.liveLayer.lineCap = .round
        self.liveLayer.lineJoin = .round
        
        self.pdfView.layer.addSublayer(self.liveLayer)
        addSubview(self.pdfView)

        NSLayoutConstraint.activate([
            self.pdfView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.pdfView.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.pdfView.topAnchor.constraint(equalTo: topAnchor),
            self.pdfView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // PAN GESTURE
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        pan.cancelsTouchesInView = true
        pan.delaysTouchesBegan = false
        addGestureRecognizer(pan)

        if let scrollPan = self.pdfView.subviews.compactMap({ $0 as? UIScrollView }).first?.panGestureRecognizer {
            
            scrollPan.minimumNumberOfTouches = 2 // two fingers to scroll
            scrollPan.require(toFail: pan) // scroll waits for draw to fail
            
        }

        self.pdfScrollView?.delaysContentTouches = false
        self.pdfScrollView?.canCancelContentTouches = true

        NotificationCenter.default.addObserver(self, selector: #selector(saveRequested), name: .pdfEditorSaveRequest, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(undoRequested), name: .pdfEditorUndoRequest, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(redoRequested), name: .pdfEditorRedoRequest, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorChanged(_:)), name: .pdfEditorColorChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(widthChanged(_:)), name: .pdfEditorWidthChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pageChanged), name: Notification.Name.PDFViewPageChanged, object: self.pdfView)
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: .pdfEditorSaveRequest, object: nil)
        NotificationCenter.default.removeObserver(self, name: .pdfEditorUndoRequest, object: nil)
        NotificationCenter.default.removeObserver(self, name: .pdfEditorRedoRequest, object: nil)
        NotificationCenter.default.removeObserver(self, name: .pdfEditorColorChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .pdfEditorWidthChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.PDFViewPageChanged, object: self.pdfView)
        
    }

    // MARK: - Drawing

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            
            guard gesture.numberOfTouches == 1 else { return }
            
            self.pdfViewScroll()?.isScrollEnabled = false

            // Start fresh paths
            self.pathViewSpace.removeAllPoints()
            self.pathPageSpace.removeAllPoints()

            let viewPoint = gesture.location(in: self.pdfView)
            
            guard let page = self.pdfView.page(for: viewPoint, nearest: true) else { return }
            self.currentPage = page

            // page-space point
            let pagePoint = self.pdfView.convert(viewPoint, to: page)

            // init paths
            self.pathViewSpace.move(to: viewPoint)
            self.pathPageSpace.move(to: pagePoint)

            // update live layer
            self.liveLayer.path = self.pathViewSpace.cgPath
            self.liveLayer.isHidden = false

        case .changed:
            
            if let page = self.currentPage,
               gesture.numberOfTouches == 1 {
                
                let viewPoint = gesture.location(in: self.pdfView)
                let pagePoint = self.pdfView.convert(viewPoint, to: page)

                self.pathViewSpace.addLine(to: viewPoint)
                self.pathPageSpace.addLine(to: pagePoint)

                self.liveLayer.path = self.pathViewSpace.cgPath
                
            }

        case .ended, .cancelled, .failed:
            
            endStroke()
            
            self.liveLayer.isHidden = true
            self.liveLayer.path = nil
            self.pdfViewScroll()?.isScrollEnabled = true

        default: break
        }
        
    }
    
    private func pdfViewScroll() -> UIScrollView? {
        self.pdfView.subviews.compactMap { $0 as? UIScrollView }.first
    }

    private func beginStroke(at viewPoint: CGPoint) {
        
        guard let page = pdfView.page(for: viewPoint, nearest: true) else { return }
        
        self.currentPage = page
        self.currentPath = UIBezierPath()
        self.currentPath.lineWidth = self.strokeWidth
        self.currentPoints = []

        let pagePoint = pdfView.convert(viewPoint, to: page)
        
        self.currentPoints.append(pagePoint)
        self.currentPath.move(to: pagePoint)
        
    }

    private func continueStroke(at viewPoint: CGPoint) {
        
        guard let page = self.currentPage else { return }
        
        let pagePoint = self.pdfView.convert(viewPoint, to: page)
        
        self.currentPoints.append(pagePoint)
        self.currentPath.addLine(to: pagePoint)
        
    }

    private func endStroke() {
        
        guard let page = self.currentPage else { return }

        // If the path is too small, ignore
        if self.pathPageSpace.isEmpty || self.pathPageSpace.bounds.size == .zero { cleanupAfterStroke(); return }

        // 1) Try INK (vector) annotation
        let ink = self.makeInkAnnotation(for: page, path: self.pathPageSpace, color: self.strokeColor, width: self.strokeWidth)
        
        page.addAnnotation(ink)
        pushUndo(annotation: ink, on: page)

        // Force refresh
        self.pdfView.setNeedsDisplay()
        self.pdfView.documentView?.setNeedsDisplay()
        
        cleanupAfterStroke()
        
    }

    private func cleanupAfterStroke() {
        
        self.currentPage = nil
        self.pathViewSpace.removeAllPoints()
        self.pathPageSpace.removeAllPoints()
        
    }

    // MARK: - Annotations

    private func makeInkAnnotation(for page: PDFPage,
                                   path pageSpacePath: UIBezierPath,
                                   color: UIColor,
                                   width: CGFloat) -> PDFAnnotation {
        
        let box = self.pdfView.displayBox                       // be consistent everywhere
        let bounds = page.bounds(for: box)                 // page rect (may not start at 0,0)

        // Translate the path from page space → annotation local space
        let localPath = UIBezierPath(cgPath: pageSpacePath.cgPath)
        localPath.apply(CGAffineTransform(translationX: -bounds.origin.x,
                                          y: -bounds.origin.y))

        let ink = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: nil)
        ink.color = color
        ink.backgroundColor = .clear
        ink.shouldDisplay = true
        ink.shouldPrint = true

        let border = PDFBorder()
        border.lineWidth = width
        ink.border = border

        // iOS API
        ink.add(localPath)
        return ink
        
    }

    private func pushUndo(annotation: PDFAnnotation, on page: PDFPage) {
        
        guard let doc = self.pdfView.document else { return }
        
        let pageIndex = doc.index(for: page)
        self.redoStacks[pageIndex] = [] // clear redo on new action
        
        var stack = self.undoStacks[pageIndex] ?? []
        stack.append(annotation)
        
        self.undoStacks[pageIndex] = stack
        
    }

    // MARK: - Undo / Redo

    @objc private func undoRequested() {
        
        guard let page = self.pdfView.currentPage,
              let doc = self.pdfView.document else { return }
        
        let idx = doc.index(for: page)
        
        guard var stack = self.undoStacks[idx], let last = stack.popLast() else { return }
        
        page.removeAnnotation(last)
        self.undoStacks[idx] = stack
        
        var r = self.redoStacks[idx] ?? []
        r.append(last)
        self.redoStacks[idx] = r
        
    }

    @objc private func redoRequested() {
        
        guard let page = self.pdfView.currentPage,
              let doc = self.pdfView.document else { return }
        
        let idx = doc.index(for: page)
        
        guard var r = self.redoStacks[idx], let last = r.popLast() else { return }
        
        page.addAnnotation(last)
        self.redoStacks[idx] = r
        
        var u = self.undoStacks[idx] ?? []
        u.append(last)
        self.undoStacks[idx] = u
        
    }

    // MARK: - Save

    @objc private func saveRequested() {
        
        guard let data = self.pdfView.document?.dataRepresentation() else { return }
        onSave?(data)
        
    }

    // MARK: - Tools

    @objc private func colorChanged(_ note: Notification) {
        
        if let c = note.object as? UIColor {
            
            self.strokeColor = c
            self.liveLayer.strokeColor = strokeColor.cgColor
            
        }
        
    }
    
    @objc private func widthChanged(_ note: Notification) {
        
        if let w = note.object as? Double {
            
            self.strokeWidth = max(0.5, min(w, 20))
            self.liveLayer.lineWidth = strokeWidth
            
        }
        
    }

    @objc private func pageChanged() {
        // no-op; annotations are on the page and move/zoom automatically
    }

    func gestureRecognizer(_ g: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        other is UIPinchGestureRecognizer
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Only begin our draw pan when it’s a single-finger gesture
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            return pan.numberOfTouches <= 1
        }
        return true
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            NotificationCenter.default.removeObserver(self)
        }
        
    }
    
}
