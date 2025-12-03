import SwiftUI
import PDFKit
import PencilKit
import UniformTypeIdentifiers
import Combine

extension PDFAnnotationKey {
    static let pencilKitData = PDFAnnotationKey(rawValue: "raw_pk_drawing_data")
}

class PDFController {

    var captureSnapshot: (() -> Data)?
    var toggleDrawing: ((Bool) -> Void)?
    var performUndo: (() -> Void)?
    var performRedo: (() -> Void)?
    
    // Callback for frame changes
    var onToolPickerFrameChange: ((CGRect) -> Void)?

    func snapshot() -> Data {
        return self.captureSnapshot?() ?? Data()
    }

    func setDrawingEnabled(_ isEnabled: Bool) {
        self.toggleDrawing?(isEnabled)
    }

    func undo() {
        self.performUndo?()
    }

    func redo() {
        self.performRedo?()
    }

    func updateToolPickerFrame(_ frame: CGRect) {
        self.onToolPickerFrameChange?(frame)
    }

}

struct PDFEditor: UIViewRepresentable {

    let document: PDFDocument
    let controller: PDFController

    func makeUIView(context: Context) -> DrawingPDFView {

        let pdfView = DrawingPDFView()
        pdfView.document = self.document

        self.controller.captureSnapshot = { [weak pdfView] in
            return pdfView?.generateSnapshot().dataRepresentation() ?? Data()
        }

        self.controller.toggleDrawing = { [weak pdfView] isEnabled in
            
            DispatchQueue.main.async {
                pdfView?.setDrawingMode(isEnabled: isEnabled)
            }
            
        }

        self.controller.performUndo = { [weak pdfView] in
            pdfView?.triggerUndo()
        }

        self.controller.performRedo = { [weak pdfView] in
            pdfView?.triggerRedo()
        }

        // Connect the frame update
        pdfView.onToolPickerFrameChanged = { [weak controller] frame in
            controller?.updateToolPickerFrame(frame)
        }

        return pdfView

    }

    func updateUIView(_ uiView: DrawingPDFView,
                      context: Context) {

        if uiView.document != self.document {
            
            uiView.document = self.document
            uiView.activeCanvas?.zoomScale = 1.0
            
        }

    }

}

@MainActor
@preconcurrency
class DrawingPDFView: PDFView,
                      PKToolPickerObserver,
                      PKCanvasViewDelegate {

    let toolPicker = PKToolPicker()
    
    var onToolPickerFrameChanged: ((CGRect) -> Void)?
    private var cancellables = Set<AnyCancellable>()

    weak var activeCanvas: PKCanvasView?

    lazy var overlayProvider: CanvasOverlayProvider = {
        return CanvasOverlayProvider(toolPicker: self.toolPicker,
                                     delegate: self)
    }()

    override init(frame: CGRect) {

        super.init(frame: frame)
        configureView()
        setupFrameObservers()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {

        self.backgroundColor = UIColor(Style.shared.background(.secondary).asColor!)
        self.autoScales = true
        self.displayMode = .singlePageContinuous
        self.displaysPageBreaks = true
        self.usePageViewController(false)
        self.pageOverlayViewProvider = self.overlayProvider
        self.isInMarkupMode = true
        self.isUserInteractionEnabled = true

    }
    
    // MARK: - Frame Observation Logic
    private func setupFrameObservers() {
        
        // iPad: The palette floats. We do NOT want to push content up.
        if UIDevice.current.userInterfaceIdiom == .pad {
            return
        }

        // iPhone: The ToolPicker acts like a Keyboard.
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification))
            .sink { [weak self] notification in
                self?.handleKeyboardChange(notification: notification)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.onToolPickerFrameChanged?(.zero)
            }
            .store(in: &cancellables)
            
    }
    
    private func handleKeyboardChange(notification: Notification) {
        
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        // We convert the keyboard frame to our view's coordinate system
        let convertedFrame = self.convert(keyboardFrame, from: nil)
        let intersection = convertedFrame.intersection(self.bounds)
        
        self.onToolPickerFrameChanged?(intersection)
        
    }

    override func didMoveToWindow() {

        super.didMoveToWindow()

        guard self.window != nil else {
            self.toolPicker.setVisible(false, forFirstResponder: self)
            self.toolPicker.removeObserver(self)
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.toolPicker.addObserver(self)
//            self.toolPicker.setVisible(true, forFirstResponder: self)
//            self.becomeFirstResponder()
            
        }

    }

    override var canBecomeFirstResponder: Bool { return true }

    func load(url: URL) {

        let savedScale = self.scaleFactor
        var savedPageIndex: Int = 0
        var savedPoint: CGPoint = .zero

        if let currentDest = self.currentDestination,
           let currentPage = currentDest.page,
           let currentDoc = self.document {

            savedPageIndex = currentDoc.index(for: currentPage)
            savedPoint = currentDest.point

        }

        self.overlayProvider.pageCanvasMap.removeAll()
        self.activeCanvas = nil

        guard let document = PDFDocument(url: url) else { return }
        self.document = document

        if savedPageIndex < document.pageCount,
           let newPage = document.page(at: savedPageIndex) {

            let newDest = PDFDestination(page: newPage, at: savedPoint)
            self.go(to: newDest)

            if savedScale > 0 {
                self.scaleFactor = savedScale
            }

        }

    }

    func setDrawingMode(isEnabled: Bool) {

        self.toolPicker.setVisible(isEnabled, forFirstResponder: self)

        for canvas in self.overlayProvider.pageCanvasMap.values {
            canvas.isUserInteractionEnabled = isEnabled
        }

        self.overlayProvider.isDrawingEnabled = isEnabled
        
        // FORCE UPDATE:
        if isEnabled {
            self.becomeFirstResponder()
        } else {
            self.resignFirstResponder()
        }

    }

    func triggerUndo() {
        self.activeCanvas?.undoManager?.undo()
    }

    func triggerRedo() {
        self.activeCanvas?.undoManager?.redo()
    }

    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        self.activeCanvas = canvasView
    }
    
    // Fallback: If on iPad, we might still get this, but we ignore it via the Idiom check in setup
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
         // No-op. We rely on Keyboard Notifications for iPhone.
    }

    func generateSnapshot() -> PDFDocument {

        guard let originalData = self.document?.dataRepresentation(),
              let workingCopy = PDFDocument(data: originalData) else {
            return PDFDocument()
        }

        for (page, canvas) in self.overlayProvider.pageCanvasMap {

            let drawing = canvas.drawing
            guard !drawing.bounds.isEmpty else { continue }

            let pageIndex = self.document?.index(for: page) ?? 0
            guard let pageCopy = workingCopy.page(at: pageIndex) else { continue }

            let bounds = pageCopy.bounds(for: .mediaBox)

            let newAnnotation = PencilKitAnnotation(
                bounds: bounds,
                forType: .stamp,
                withProperties: nil
            )

            newAnnotation.drawing = drawing
            newAnnotation.pageBounds = bounds

            let data = drawing.dataRepresentation()
            newAnnotation.setValue(data, forAnnotationKey: .pencilKitData)

            pageCopy.addAnnotation(newAnnotation)

        }

        return workingCopy

    }

}

@MainActor
@preconcurrency
class CanvasOverlayProvider: NSObject,
                             @preconcurrency PDFPageOverlayViewProvider {

    var pageCanvasMap: [PDFPage: PKCanvasView] = [:]

    weak var toolPicker: PKToolPicker?
    weak var delegate: PKCanvasViewDelegate?

    var isDrawingEnabled: Bool = true

    init(toolPicker: PKToolPicker,
         delegate: PKCanvasViewDelegate) {

        self.toolPicker = toolPicker
        self.delegate = delegate

    }

    func pdfView(_ view: PDFView,
                 overlayViewFor page: PDFPage) -> UIView? {

        if let existingCanvas = pageCanvasMap[page] {
            return existingCanvas
        }

        let canvas = PKCanvasView(frame: .zero)
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.isUserInteractionEnabled = self.isDrawingEnabled
        canvas.delegate = self.delegate
        
        for annotation in page.annotations {
            if let data = annotation.value(forAnnotationKey: .pencilKitData) as? Data {
                try? canvas.drawing = PKDrawing(data: data)
                page.removeAnnotation(annotation)
            }
        }

        self.toolPicker?.addObserver(canvas)
        self.pageCanvasMap[page] = canvas

        return canvas

    }

    func pdfView(_ pdfView: PDFView,
                 willEndDisplayingOverlayView overlayView: UIView,
                 for page: PDFPage) {

    }

}

class PencilKitAnnotation: PDFAnnotation {

    var drawing: PKDrawing?
    var pageBounds: CGRect = .zero

    override func draw(with box: PDFDisplayBox,
                       in context: CGContext) {

        guard let drawing = self.drawing else { return }

        let image = drawing.image(from: self.pageBounds, scale: 1.0)
        guard let cgImage = image.cgImage else { return }

        context.saveGState()

        let flipRect = CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y + bounds.height,
            width: bounds.width,
            height: -bounds.height
        )

        context.draw(cgImage, in: flipRect)
        context.restoreGState()

    }

}
