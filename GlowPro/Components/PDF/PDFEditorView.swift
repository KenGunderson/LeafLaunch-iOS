//
//  PDFEditorView.swift
//  GlowPro
//
//  Created by Kenneth Gunderson on 10/25/25.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFEditorView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let onSave: (Data) -> Void

    @StateObject private var pdfEditorViewModel: PDFEditorViewModel
    
    @State private var pdfCommand: PDFCommand?
    @State private var pdfDocument: PDFDocument

    init(pdfDocument: PDFDocument,
         onSave: @escaping (Data) -> Void) {
        
        self._pdfEditorViewModel = .init(wrappedValue: .init())
        self.pdfDocument = pdfDocument
        self.onSave = onSave
        
    }
    
    var body: some View {
        content()
    }
    
    private func content() -> some View {
     
        AppBaseView {
            buildPDFView()
        }
        .safeAreaInset(edge: .top) {
            navBar()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .close) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "PDF Editor",
            leftButtonView: backButton,
        )
        
    }
    
    private func buildPDFView() -> some View {
        
        PDFInkView(document: self.pdfDocument,
                   viewModel: .init(),
                   onAction: { action in
            
            switch action {
            case .didSave(let data):
                
                onSave(data)
                dismiss()
                
            default: break
            }
            
        }, command: self.$pdfCommand)
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            toolBar()
            saveButton()
            
        }
        .padding(.horizontal, .medium)
        .frame(maxWidth: .infinity)
        .background(Style.shared.background(.primary).source())
        
    }
    
    private func toolBar() -> some View {
        
        VStack {
            
            HStack {
                
                scrollOrPanTool()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                
                undoRedo()
                
            }
            
            HStack(spacing: Style.shared.spacing(.small)) {
                
                HStack {
                    
                    colorPicker()
                    pencilTool()
                    highlighterTool()
//                    eraserTool()
                    
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                
                lineWidthSlider()
                    .offset(y: 5)
                
            }
            
        }
        .padding(.small)
        
    }
    
    @ViewBuilder
    private func colorPicker() -> some View {
        
        ColorPicker("", selection: self.$pdfEditorViewModel.strokeColor)
            .labelsHidden()
            .frame(width: 32, height: 32)
            .onChange(of: self.pdfEditorViewModel.strokeColor) { _, new in
                self.pdfCommand = .setStroke(color: UIColor(new))
            }
        
    }
    
    @ViewBuilder
    private func pencilTool() -> some View {
        
        toolButton(
            systemImage: "pencil",
            isSelected: self.pdfEditorViewModel.currentTool == .pen
        )
        .asButton {
            
            if self.pdfEditorViewModel.currentTool == .pen {
                
                resetTool()
                return
                
            }
            
            self.pdfEditorViewModel.currentTool = .pen
            self.pdfCommand = .setTool(.pen)
            
        }
        
    }
    
    @ViewBuilder
    private func highlighterTool() -> some View {
        
        let highlighterTool = PDFTool.highlighter(alpha: 0.35)
                
        toolButton(
            systemImage: "highlighter",
            isSelected: self.pdfEditorViewModel.currentTool == highlighterTool
        )
        .asButton {
            
            if self.pdfEditorViewModel.currentTool == highlighterTool {
                
                resetTool()
                return
                
            }
            
            self.pdfEditorViewModel.currentTool = highlighterTool
            self.pdfCommand = .setTool(highlighterTool)
            
        }
        
    }
    
    @ViewBuilder
    private func eraserTool() -> some View {
        
        let eraserTool = PDFTool.eraser(mode: .byHitTest)

        toolButton(
            systemImage: "eraser",
            isSelected: self.pdfEditorViewModel.currentTool == eraserTool
        )
        .asButton {
            
            if self.pdfEditorViewModel.currentTool == eraserTool {
                
                resetTool()
                return
                
            }
            
            self.pdfEditorViewModel.currentTool = eraserTool
            self.pdfCommand = .setTool(eraserTool)
            
        }
        
    }
    
    @ViewBuilder
    private func scrollOrPanTool() -> some View {
        
        let isSelected = self.pdfEditorViewModel.currentTool == .scrollAndPan
        
        let backgroundStyle = isSelected
            ? Style.shared.accent
            : Style.shared.background(.quaternary)
        
        let foregroundStyle = isSelected
            ? Style.shared.textColor(.button)
            : Style.shared.textColor(.title)
     
        TokenView(
            text: "Zoom And Pan",
            foregroundStyle: foregroundStyle,
            backgroundStyle: backgroundStyle
        )
        .asButton {
                        
            if isSelected {
                
                self.pdfEditorViewModel
                    .currentTool = self.pdfEditorViewModel.toolBeforeGesture ?? .pen
                
                self.pdfCommand = .setTool(self.pdfEditorViewModel.toolBeforeGesture ?? .pen)
                
                self.pdfEditorViewModel
                    .toolBeforeGesture = nil
                
            } else {
                
                self.pdfEditorViewModel
                    .toolBeforeGesture = self.pdfEditorViewModel.currentTool
                
                self.pdfEditorViewModel
                    .currentTool = .scrollAndPan
                
                self.pdfCommand = .setTool(.scrollAndPan)
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func lineWidthSlider() -> some View {
        
        VStack(alignment: .leading, spacing: -6) {
            
            Text("Line Width")
                .appFont(with: .TITLE_2)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
            ProgressSlider(value: self.$pdfEditorViewModel.strokeWidth, thumbHeight: 24)
                .onChange(of: self.pdfEditorViewModel.strokeWidth) { _, new in
                    
                    let finalValue = Double(10 * new)
                    self.pdfCommand = .setWidth(finalValue)
                    
                }
            
        }
        .frame(maxWidth: .infinity, alignment: .center)
        
    }
    
    @ViewBuilder
    private func toolButton(systemImage: String,
                            isSelected: Bool) -> some View {
        
        let unselectedForegroundColor = Style.shared.textColor(.title)
        let unselectedBackgroundColor = Style.shared.background(.quaternary)
        
        let selectedBackgroundColor = Style.shared.accent
        let selectedForegroundColor = Style.shared.textColor(.titleInverted)
        
        CircularIconView(
            foregroundColor: isSelected ? selectedForegroundColor : unselectedForegroundColor,
            backgroundColor: isSelected ? selectedBackgroundColor : unselectedBackgroundColor,
            imageSource: .systemImage(systemImage),
            size: 32
        )
        
    }
    
    @ViewBuilder
    private func undoRedo() -> some View {
        
        HStack {
            
            Button {
                
                self.pdfCommand = .undo
                
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .foregroundStyle(Style.shared.accent.source())
            .appFont(with: .HEADER_1)
            
            Button {
                
                self.pdfCommand = .redo
                
            } label: {
                Image(systemName: "arrow.uturn.forward")
            }
            .foregroundStyle(Style.shared.accent.source())
            .appFont(with: .HEADER_1)
            
        }
        
    }
    
    private func saveButton() -> some View {
        
        CommonButton(
            title: "Save"
        ) {
            self.pdfCommand = .save
        }
        
    }
    
    private func resetTool() {
        
        self.pdfEditorViewModel.currentTool = .none
        self.pdfCommand = .setTool(.none)
        
    }
    
}

#Preview {
    
    let url = Bundle.main.url(forResource: "PainDiagram", withExtension: "pdf")!
    let pdfDoucment = PDFDocument(url: url)!
    
    PDFEditorView(pdfDocument: pdfDoucment) { editedData in
        print("Edited PDF size: \(editedData.count) bytes")
    }
    
}
