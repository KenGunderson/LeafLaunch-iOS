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

        self.pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.pdfView.autoScales = true
        self.pdfView.displayMode = .singlePageContinuous
        self.pdfView.displayDirection = .vertical
        self.pdfView.displaysPageBreaks = true
        self.pdfView.displayBox = .cropBox
        self.pdfView.backgroundColor = .clear

        // Live stroke layer sits above the PDF content
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

        // Pan = drawing
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        pan.cancelsTouchesInView = true
        pan.delaysTouchesBegan = false
        addGestureRecognizer(pan)

        if let scrollPan = self.pdfView.subviews.compactMap({ $0 as? UIScrollView }).first?.panGestureRecognizer {
            
            scrollPan.minimumNumberOfTouches = 2   // two fingers to scroll
            scrollPan.require(toFail: pan)         // scroll waits for draw to fail
            
        }

        // Optional nicety: let the scroll view react quicker when not drawing
        self.pdfScrollView?.delaysContentTouches = false
        self.pdfScrollView?.canCancelContentTouches = true

        // Observe UI actions
        NotificationCenter.default.addObserver(self, selector: #selector(saveRequested), name: .pdfEditorSaveRequest, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(undoRequested), name: .pdfEditorUndoRequest, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(redoRequested), name: .pdfEditorRedoRequest, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorChanged(_:)), name: .pdfEditorColorChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(widthChanged(_:)), name: .pdfEditorWidthChanged, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(pageChanged), name: Notification.Name.PDFViewPageChanged, object: self.pdfView)
        
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

    // MARK: - Drawing

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        
        switch g.state {
        case .began:
            guard g.numberOfTouches == 1 else { return }
            pdfViewScroll()?.isScrollEnabled = false

            // Start fresh paths
            pathViewSpace.removeAllPoints()
            pathPageSpace.removeAllPoints()

            let viewPt = g.location(in: pdfView)
            guard let page = pdfView.page(for: viewPt, nearest: true) else { return }
            currentPage = page

            // page-space point
            let pagePt = pdfView.convert(viewPt, to: page)

            // init paths
            pathViewSpace.move(to: viewPt)
            pathPageSpace.move(to: pagePt)

            // update live layer
            liveLayer.path = pathViewSpace.cgPath
            liveLayer.isHidden = false

        case .changed:
            if g.numberOfTouches == 1, let page = currentPage {
                let viewPt = g.location(in: pdfView)
                let pagePt = pdfView.convert(viewPt, to: page)

                pathViewSpace.addLine(to: viewPt)
                pathPageSpace.addLine(to: pagePt)

                liveLayer.path = pathViewSpace.cgPath
            }

        case .ended, .cancelled, .failed:
            endStroke()                         // <- always run
            liveLayer.isHidden = true
            liveLayer.path = nil
            pdfViewScroll()?.isScrollEnabled = true

        default: break
        }
        
    }
    
    private func pdfViewScroll() -> UIScrollView? {
        pdfView.subviews.compactMap { $0 as? UIScrollView }.first
    }

    private func beginStroke(at viewPoint: CGPoint) {
        
        guard let page = pdfView.page(for: viewPoint, nearest: true) else { return }
        currentPage = page
        currentPath = UIBezierPath()
        currentPath.lineWidth = strokeWidth
        currentPoints = []

        let pagePoint = pdfView.convert(viewPoint, to: page)
        currentPoints.append(pagePoint)
        currentPath.move(to: pagePoint)
        
    }

    private func continueStroke(at viewPoint: CGPoint) {
        
        guard let page = currentPage else { return }
        let pagePoint = pdfView.convert(viewPoint, to: page)
        currentPoints.append(pagePoint)
        currentPath.addLine(to: pagePoint)
        
    }

    private func endStroke() {
        
        guard let page = currentPage else { return }

        // If the path is too small, ignore
        if pathPageSpace.isEmpty || pathPageSpace.bounds.size == .zero { cleanupAfterStroke(); return }

        // 1) Try INK (vector) annotation
        let ink = makeInkAnnotation(for: page, path: pathPageSpace, color: strokeColor, width: strokeWidth)
        
        page.addAnnotation(ink)
        pushUndo(annotation: ink, on: page)

        // Force refresh
        pdfView.setNeedsDisplay()
        pdfView.documentView?.setNeedsDisplay()
        cleanupAfterStroke()
        
    }

    private func cleanupAfterStroke() {
        
        currentPage = nil
        pathViewSpace.removeAllPoints()
        pathPageSpace.removeAllPoints()
        
    }

    // MARK: - Annotations

    private func makeInkAnnotation(for page: PDFPage,
                                   path pageSpacePath: UIBezierPath,
                                   color: UIColor,
                                   width: CGFloat) -> PDFAnnotation {
        
        let box = pdfView.displayBox                       // be consistent everywhere
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
        
        guard let doc = pdfView.document else { return }
        let pageIndex = doc.index(for: page)
        redoStacks[pageIndex] = [] // clear redo on new action
        var stack = undoStacks[pageIndex] ?? []
        stack.append(annotation)
        undoStacks[pageIndex] = stack
        
    }

    // MARK: - Undo / Redo

    @objc private func undoRequested() {
        
        guard let page = pdfView.currentPage,
              let doc = pdfView.document else { return }
        let idx = doc.index(for: page)
        guard var stack = undoStacks[idx], let last = stack.popLast() else { return }
        page.removeAnnotation(last)
        undoStacks[idx] = stack
        var r = redoStacks[idx] ?? []
        r.append(last)
        redoStacks[idx] = r
        
    }

    @objc private func redoRequested() {
        
        guard let page = pdfView.currentPage,
              let doc = pdfView.document else { return }
        let idx = doc.index(for: page)
        guard var r = redoStacks[idx], let last = r.popLast() else { return }
        page.addAnnotation(last)
        redoStacks[idx] = r
        var u = undoStacks[idx] ?? []
        u.append(last)
        undoStacks[idx] = u
        
    }

    // MARK: - Save

    @objc private func saveRequested() {
        
        guard let data = pdfView.document?.dataRepresentation() else { return }
        onSave?(data)
        
    }

    // MARK: - Tools

    @objc private func colorChanged(_ note: Notification) {
        
        if let c = note.object as? UIColor {
            
            strokeColor = c
            liveLayer.strokeColor = strokeColor.cgColor
            
        }
        
    }
    
    @objc private func widthChanged(_ note: Notification) {
        
        if let w = note.object as? Double {
            
            strokeWidth = max(0.5, min(w, 20))
            liveLayer.lineWidth = strokeWidth
            
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
