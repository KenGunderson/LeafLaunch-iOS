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
        
        PDFInkView(document: self.pdfDocument, viewModel: .init(), onAction: { action in
            
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
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            HStack {
                
                ColorPicker("", selection: self.$pdfEditorViewModel.strokeColor)
                    .labelsHidden()
                    .frame(width: 32, height: 32)
                    .onChange(of: self.pdfEditorViewModel.strokeColor) { _, new in
                        self.pdfCommand = .setStroke(color: UIColor(new))
                    }
                
                let eraserTool = PDFTool.eraser(mode: .byHitTest)
                let highlighterTool = PDFTool.highlighter(alpha: 0.35)
                
                let unselectedForegroundColor = Style.shared.textColor(.title)
                let unselectedBackgroundColor = Style.shared.background(.quaternary)
                
                let selectedBackgroundColor = Style.shared.accent
                let selectedForegroundColor = Style.shared.textColor(.titleInverted)
                
                CircularIconView(
                    foregroundColor: self.pdfEditorViewModel.currentTool == .pen ? selectedForegroundColor : unselectedForegroundColor,
                    backgroundColor: self.pdfEditorViewModel.currentTool == .pen ? selectedBackgroundColor : unselectedBackgroundColor,
                    imageSource: .systemImage("pencil"),
                    size: 32
                )
                .asButton {
                    
                    self.pdfEditorViewModel.currentTool = .pen
                    self.pdfCommand = .setTool(.pen)
                    
                }
                
                CircularIconView(
                    foregroundColor: self.pdfEditorViewModel.currentTool == highlighterTool ? selectedForegroundColor : unselectedForegroundColor,
                    backgroundColor: self.pdfEditorViewModel.currentTool == highlighterTool ? selectedBackgroundColor : unselectedBackgroundColor,
                    imageSource: .systemImage("highlighter"),
                    size: 32
                )
                .asButton {
                    
                    self.pdfEditorViewModel.currentTool = highlighterTool
                    self.pdfCommand = .setTool(highlighterTool)
                    
                }
                
                CircularIconView(
                    foregroundColor: self.pdfEditorViewModel.currentTool == eraserTool ? selectedForegroundColor : unselectedForegroundColor,
                    backgroundColor: self.pdfEditorViewModel.currentTool == eraserTool ? selectedBackgroundColor : unselectedBackgroundColor,
                    imageSource: .systemImage("eraser"),
                    size: 32
                )
                .asButton {
                    
                    self.pdfEditorViewModel.currentTool = eraserTool
                    self.pdfCommand = .setTool(eraserTool)
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)

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
            .offset(y: 5)
            
            Spacer(minLength: 24)
            
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
        .padding(.small)
        
    }
    
    private func saveButton() -> some View {
        
        CommonButton(
            title: "Save"
        ) {
            self.pdfCommand = .save
        }
        
    }
    
}

#Preview {
    
    let url = Bundle.main.url(forResource: "PainDiagram", withExtension: "pdf")!
    let pdfDoucment = PDFDocument(url: url)!
    
    PDFEditorView(pdfDocument: pdfDoucment) { editedData in
        print("Edited PDF size: \(editedData.count) bytes")
    }
    
}
