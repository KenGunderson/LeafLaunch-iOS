//
//  PDFInkView.swift
//  GlowPro
//
//  Created by Kenneth Gunderson on 10/25/25.
//

import SwiftUI
import PDFKit

struct PDFInkView: UIViewRepresentable {
    
    // MARK: Init
    
    public init(document: PDFDocument,
                viewModel: PDFEditorViewModel,
                onAction: @escaping (PDFAction) -> Void,
                command: Binding<PDFCommand?>) {
        
        self.document = document
        self._viewModel = .init(wrappedValue: viewModel)
        self.onAction = onAction
        self._command = command
        
    }
    
    // MARK: Stored Properties
    
    private let document: PDFDocument
    
    @ObservedObject
    private var viewModel: PDFEditorViewModel
    
    private let onAction: (PDFAction) -> Void
    
    @Binding
    private var command: PDFCommand?
    
    var pages: [PDFPage] {
        return self.document.pages
    }
    
    // MARK: UIViewRepresentable
    
    public func makeUIView(context: Context) -> InkContainer {
        
        let container = InkContainer { action in
            
            self.onAction(action)
            
            switch action {
            case .didChangeTool(let tool):
                
                self.viewModel.currentTool = tool
                
            case .didChangeStroke(let color, let width):
                
                self.viewModel.strokeColor = Color(uiColor: color)
                self.viewModel.strokeWidth = width
                
            case .undoAvailability(let canUndo, let canRedo):
                
                self.viewModel.canUndo = canUndo
                self.viewModel.canRedo = canRedo
                
            case .didJumpToPage(let index, let count):
                
                self.viewModel.pageIndex = index
                self.viewModel.pageCount = count
                
            case .didSave, .error:
                break
            }
            
        }
        
        container.configure(
            document: self.document,
            initialTool: self.viewModel.currentTool,
            color: UIColor(self.viewModel.strokeColor),
            width: self.viewModel.strokeWidth * 10
        )
        
        return container
        
    }
    
    public func updateUIView(_ uiView: InkContainer, context: Context) {
        
        if let cmd = self.command {
            uiView.handle(command: cmd)
            
            DispatchQueue.main.async {
                self.command = nil
            }
        }
    }
}

// MARK: - InkContainer

@MainActor
final class InkContainer: UIView, UIGestureRecognizerDelegate {
    
    // MARK: Core
    
    private let pdfView = PDFView()
    private let onAction: (PDFAction) -> Void
    
    // MARK: Drawing State
    
    private var currentPage: PDFPage?
    private var pathViewSpace = UIBezierPath()
    private var pathPageSpace = UIBezierPath()
    
    // MARK: Settings
    
    private var currentTool: PDFTool = .pen
    private var strokeColor: UIColor = .black
    private var strokeWidth: CGFloat = 2.5
    
    // MARK: Layers
    
    private var liveLayer = CAShapeLayer()
    
    // MARK: Undo / Redo (per page)
    
    private var undoStacks: [Int: [PDFAnnotation]] = [:]
    private var redoStacks: [Int: [PDFAnnotation]] = [:]
    
    // MARK: Gestures
    
    private lazy var drawPan: UIPanGestureRecognizer = {
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        pan.cancelsTouchesInView = true
        pan.delaysTouchesBegan = false
        pan.delegate = self
        return pan
        
    }()
    
    private weak var scrollPan: UIPanGestureRecognizer?
    
    // MARK: Init
    
    init(onAction: @escaping (PDFAction) -> Void) {
        
        self.onAction = onAction
        super.init(frame: .zero)
        self.setupSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: Configure
    
    func configure(document: PDFDocument,
                   initialTool: PDFTool,
                   color: UIColor,
                   width: CGFloat) {
        
        self.pdfView.document = document
        self.currentTool = initialTool
        self.strokeColor = color
        self.strokeWidth = width
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            
            let fit = self.pdfView.scaleFactorForSizeToFit
            self.pdfView.minScaleFactor = fit * 1.0
            self.pdfView.maxScaleFactor = fit * 8.0
            self.pdfView.scaleFactor = fit
            
            self.configureGestures(for: self.currentTool)
            
            self.emitPageChange()
            self.emitUndoAvailability()
            self.onAction(.didChangeTool(self.currentTool))
            self.onAction(.didChangeStroke(color: self.strokeColor, width: self.strokeWidth))
            
        }
        
    }
    
    // MARK: Subviews
    
    private func setupSubviews() {
        
        // PDF View
        self.pdfView.translatesAutoresizingMaskIntoConstraints = false
        self.pdfView.autoScales = true
        self.pdfView.displayMode = .singlePageContinuous
        self.pdfView.displayDirection = .vertical
        self.pdfView.displaysPageBreaks = true
        self.pdfView.displayBox = .cropBox
        self.pdfView.backgroundColor = .clear
        
        // Live Layer
        self.liveLayer.strokeColor = self.strokeColor.cgColor
        self.liveLayer.fillColor = UIColor.clear.cgColor
        self.liveLayer.lineWidth = self.strokeWidth
        self.liveLayer.lineCap = .round
        self.liveLayer.lineJoin = .round
        
        self.pdfView.layer.addSublayer(self.liveLayer)
        self.addSubview(self.pdfView)
        
        NSLayoutConstraint.activate([
            self.pdfView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.pdfView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.pdfView.topAnchor.constraint(equalTo: self.topAnchor),
            self.pdfView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        // PDF Scroll Pan
        self.scrollPan = self.pdfScrollView?.panGestureRecognizer
        
        // Our Drawing Recognizer
        self.addGestureRecognizer(self.drawPan)
        
        // Touch Behavior
        self.pdfScrollView?.delaysContentTouches = false
        self.pdfScrollView?.canCancelContentTouches = true
        
        // Default Mode: no tool → natural scrolling
        self.configureGestures(for: .none)
        
        // Page Change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.pageChanged),
            name: Notification.Name.PDFViewPageChanged,
            object: self.pdfView
        )
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name.PDFViewPageChanged,
            object: self.pdfView
        )
        
    }
    
    private var pdfScrollView: UIScrollView? {
        self.pdfView.subviews.compactMap { $0 as? UIScrollView }.first
    }
    
    // MARK: Commands
    
    func handle(command: PDFCommand) {
        
        switch command {
        case .save:
            
            if let data = self.pdfView.document?.dataRepresentation() {
                self.onAction(.didSave(data: data))
            }
            
        case .undo:
            
            self.undoRequested()
            
        case .redo:
            
            self.redoRequested()
            
        case .setTool(let tool):
            
            self.currentTool = tool
            self.onAction(.didChangeTool(tool))
            self.liveLayer.opacity = (tool == .none) ? 0 : 1
            self.configureGestures(for: tool)
            
        case .setStroke(let color):
            
            self.strokeColor = color
            self.liveLayer.strokeColor = color.cgColor
            self.onAction(.didChangeStroke(color: color, width: self.strokeWidth))
            
        case .setWidth(let width):
            
            self.strokeWidth = max(0.5, min(width, 20))
            self.liveLayer.lineWidth = self.strokeWidth
            self.onAction(.didChangeStroke(color: self.strokeColor, width: self.strokeWidth))
            
        case .replaceDocument(let doc):
            
            self.configure(
                document: doc,
                initialTool: self.currentTool,
                color: self.strokeColor,
                width: self.strokeWidth
            )
            
        case .jumpToPage(let index):
            
            if let page = self.pdfView.document?.page(at: index) {
                
                self.pdfView.go(to: page)
                self.emitPageChange()
                
            }
            
        case .clearCurrentPage:
            self.clearAnnotationsOnCurrentPage()
            
        case .export(let mode):
            
            switch mode {
                
            case .originalWithAnnotations:
                
                if let data = self.pdfView.document?.dataRepresentation() {
                    self.onAction(.didSave(data: data))
                }
                
            }
            
        }
        
        self.emitUndoAvailability()
        
    }
    
    // MARK: Gesture Mode Switching
    
    private func configureGestures(for tool: PDFTool) {
        
        let drawingActive: Bool
        
        switch tool {
        case .pen, .highlighter, .eraser: drawingActive = true
        case .none: drawingActive = false
        }
        
        // Our drawing: 1-finger when active; disabled when no tool
        self.drawPan.isEnabled = drawingActive
        
        // PDF scroll: always enabled; 1-finger when no tool, 2-finger when drawing
        self.pdfScrollView?.isScrollEnabled = true
        self.scrollPan?.isEnabled = true
        self.scrollPan?.minimumNumberOfTouches = drawingActive ? 2 : 1
        
        // When drawing, make scroll wait for drawPan
        if drawingActive {
            
            if let scrollPan { scrollPan.require(toFail: self.drawPan) }
            self.liveLayer.isHidden = false
            self.liveLayer.opacity = 1
            
        } else {
            
            self.liveLayer.isHidden = true
            self.liveLayer.opacity = 0
            
        }
        
    }
    
    // MARK: Gesture Handling
    
    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        switch self.currentTool {
        case .pen, .highlighter:
            
            self.handleDrawPan(gesture)
            
        case .eraser(let mode):
            
            switch mode {
            case .lastStroke:
                
                if gesture.state == .ended {
                    self.eraseLastStroke()
                }
                
            case .byHitTest: self.handleEraseHitTestPan(gesture)
            }
            
        case .none:
            break
        }
        
    }
    
    // MARK: Drawing
    
    private func handleDrawPan(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            
            guard self.currentTool != .none else { return }
            guard gesture.numberOfTouches == 1 else { return }
            
            self.pdfScrollView?.isScrollEnabled = false
            
            self.pathViewSpace.removeAllPoints()
            self.pathPageSpace.removeAllPoints()
            
            let viewPoint = gesture.location(in: self.pdfView)
            guard let page = self.pdfView.page(for: viewPoint, nearest: true) else { return }
            self.currentPage = page
            
            let pagePoint = self.pdfView.convert(viewPoint, to: page)
            self.pathViewSpace.move(to: viewPoint)
            self.pathPageSpace.move(to: pagePoint)
            
            let (color, width, alpha) = self.strokeForCurrentTool()
            self.liveLayer.strokeColor = color.withAlphaComponent(alpha).cgColor
            self.liveLayer.lineWidth = width
            self.liveLayer.isHidden = false
            
        case .changed:
            
            guard self.currentTool != .none else { return }
            
            if let page = self.currentPage, gesture.numberOfTouches == 1 {
                
                let viewPoint = gesture.location(in: self.pdfView)
                let pagePoint = self.pdfView.convert(viewPoint, to: page)
                
                self.pathViewSpace.addLine(to: viewPoint)
                self.pathPageSpace.addLine(to: pagePoint)
                self.liveLayer.path = self.pathViewSpace.cgPath
                
            }
            
        case .ended, .cancelled, .failed:
            
            self.commitStroke()
            self.liveLayer.isHidden = true
            self.liveLayer.path = nil
            self.pdfScrollView?.isScrollEnabled = true
            
        default:
            break
        }
        
    }
    
    private func strokeForCurrentTool() -> (UIColor, CGFloat, CGFloat) {
        
        switch self.currentTool {
        case .pen:

            return (self.strokeColor, self.strokeWidth, 1.0)
            
        case .highlighter(let alpha):
            
            let clamped = max(0.1, min(alpha, 0.6))
            let width = self.strokeWidth * 3 * 2
            return (self.strokeColor, width, clamped)
            
        case .eraser:
            
            return (self.strokeColor, self.strokeWidth, 1.0) // unused
            
        case .none:
            return (.red, 0, 0)
        }
        
    }
    
    private func commitStroke() {
        
        guard let page = self.currentPage else {
            
            self.cleanupAfterStroke()
            return
            
        }
        
        guard self.pathPageSpace.isEmpty == false,
              self.pathPageSpace.bounds.size != .zero else {
            
            self.cleanupAfterStroke()
            return
            
        }
        
        let (color, width, alpha) = self.strokeForCurrentTool()
        
        let ink = self.makeInkAnnotation(
            for: page,
            path: self.pathPageSpace,
            color: color.withAlphaComponent(alpha),
            width: width
        )
        
        page.addAnnotation(ink)
        self.pushUndo(annotation: ink, on: page)
        
        self.pdfView.setNeedsDisplay()
        self.pdfView.documentView?.setNeedsDisplay()
        
        self.cleanupAfterStroke()
        self.emitUndoAvailability()
        
    }
    
    private func cleanupAfterStroke() {
        
        self.currentPage = nil
        self.pathViewSpace.removeAllPoints()
        self.pathPageSpace.removeAllPoints()
        
    }
    
    // MARK: Eraser (by-hit-test)
    
    private func handleEraseHitTestPan(_ gesture: UIPanGestureRecognizer) {
        
        guard let page = self.pdfView.currentPage else { return }
        
        let viewPoint = gesture.location(in: self.pdfView)
        let pagePoint = self.pdfView.convert(viewPoint, to: page)
        
        if gesture.state == .ended {
            self.eraseNearestAnnotation(at: pagePoint, on: page)
        }
        
    }
    
    private func eraseNearestAnnotation(at point: CGPoint, on page: PDFPage) {
        
        let annotations = page.annotations
        guard annotations.isEmpty == false else { return }
        
        let tolerance: CGFloat = 14.0
        
        let candidates = annotations.filter {
            $0.bounds.insetBy(dx: -tolerance, dy: -tolerance).contains(point)
        }
        
        let target = candidates.first ?? annotations.min {
            $0.bounds.center.distance(to: point) < $1.bounds.center.distance(to: point)
        }
        
        guard let hit = target else { return }
        
        page.removeAnnotation(hit)
        self.pushRedoAfterRemoval(hit, on: page)
        
        self.emitUndoAvailability()
        self.pdfView.setNeedsDisplay()
        
    }
    
    private func eraseLastStroke() {
        
        guard let page = self.pdfView.currentPage,
              let doc = self.pdfView.document else { return }
        
        let idx = doc.index(for: page)
        
        guard var stack = self.undoStacks[idx],
              let last = stack.popLast() else { return }
        
        page.removeAnnotation(last)
        self.undoStacks[idx] = stack
        
        var redo = self.redoStacks[idx] ?? []
        redo.append(last)
        self.redoStacks[idx] = redo
        
        self.emitUndoAvailability()
        self.pdfView.setNeedsDisplay()
        
    }
    
    // MARK: Annotations
    
    private func makeInkAnnotation(for page: PDFPage,
                                   path pageSpacePath: UIBezierPath,
                                   color: UIColor,
                                   width: CGFloat) -> PDFAnnotation {
        
        let box = self.pdfView.displayBox
        let bounds = page.bounds(for: box)
        
        let localPath = UIBezierPath(cgPath: pageSpacePath.cgPath)
        localPath.apply(CGAffineTransform(
            translationX: -bounds.origin.x,
            y: -bounds.origin.y
        ))
        
        let ink = PDFAnnotation(bounds: bounds, forType: .ink, withProperties: nil)
        ink.color = color
        ink.backgroundColor = .clear
        ink.shouldDisplay = true
        ink.shouldPrint = true
        
        let border = PDFBorder()
        border.lineWidth = width
        ink.border = border
        
        ink.add(localPath)
        return ink
        
    }
    
    private func pushUndo(annotation: PDFAnnotation, on page: PDFPage) {
        
        guard let doc = self.pdfView.document else { return }
        
        let pageIndex = doc.index(for: page)
        self.redoStacks[pageIndex] = []
        
        var stack = self.undoStacks[pageIndex] ?? []
        stack.append(annotation)
        self.undoStacks[pageIndex] = stack
        
    }
    
    private func pushRedoAfterRemoval(_ removed: PDFAnnotation, on page: PDFPage) {
        
        guard let doc = self.pdfView.document else { return }
        
        let idx = doc.index(for: page)
        var redo = self.redoStacks[idx] ?? []
        redo.append(removed)
        self.redoStacks[idx] = redo
        
    }
    
    // MARK: Undo / Redo
    
    private func undoRequested() {
        
        guard let page = self.pdfView.currentPage,
              let doc = self.pdfView.document else { return }
        
        let idx = doc.index(for: page)
        
        guard var stack = self.undoStacks[idx],
              let last = stack.popLast() else { return }
        
        page.removeAnnotation(last)
        self.undoStacks[idx] = stack
        
        var redo = self.redoStacks[idx] ?? []
        redo.append(last)
        self.redoStacks[idx] = redo
        
        self.emitUndoAvailability()
        
    }
    
    private func redoRequested() {
        
        guard let page = self.pdfView.currentPage,
              let doc = self.pdfView.document else { return }
        
        let idx = doc.index(for: page)
        
        guard var redo = self.redoStacks[idx],
              let last = redo.popLast() else { return }
        
        page.addAnnotation(last)
        self.redoStacks[idx] = redo
        
        var undo = self.undoStacks[idx] ?? []
        undo.append(last)
        self.undoStacks[idx] = undo
        
        self.emitUndoAvailability()
        
    }
    
    private func emitUndoAvailability() {
        
        guard let doc = self.pdfView.document,
              let page = self.pdfView.currentPage else { return }
        
        let idx = doc.index(for: page)
        let canUndo = (self.undoStacks[idx]?.isEmpty == false)
        let canRedo = (self.redoStacks[idx]?.isEmpty == false)
        
        self.onAction(.undoAvailability(canUndo: canUndo, canRedo: canRedo))
        
    }
    
    // MARK: Save / Page
    
    @objc
    private func pageChanged() {
        self.emitPageChange()
    }
    
    private func emitPageChange() {
        
        if let doc = self.pdfView.document,
           let page = self.pdfView.currentPage {
            self.onAction(.didJumpToPage(index: doc.index(for: page), count: doc.pageCount))
        }
        
    }
    
    private func clearAnnotationsOnCurrentPage() {
        
        guard let page = self.pdfView.currentPage else { return }
        
        for ann in page.annotations {
            page.removeAnnotation(ann)
        }
        
        self.emitUndoAvailability()
        self.pdfView.setNeedsDisplay()
        
    }
    
    // MARK: Gesture Delegate
    
    func gestureRecognizer(_ g: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        other is UIPinchGestureRecognizer
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            return pan.numberOfTouches <= 1
        }
        
        return true
        
    }
    
}

// MARK: - Small Geometry Helpers

private extension CGRect {
    
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
    
}

private extension CGPoint {
    
    func distance(to other: CGPoint) -> CGFloat {
        let dx = self.x - other.x
        let dy = self.y - other.y
        return sqrt(dx * dx + dy * dy)
    }
    
}

extension PDFDocument {
    
    var pages: [PDFPage] {
        (0..<self.pageCount).compactMap { self.page(at: $0) }
    }
    
}
