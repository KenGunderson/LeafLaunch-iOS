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

    @State private var pdfDocument: PDFDocument
    @State private var selectedToolbarLineWidth: Double = 0.25
    @State private var selectedToolbarColor: Color = .black

    init(pdfDocument: PDFDocument,
         onSave: @escaping (Data) -> Void) {
        
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
        
        PDFInkView(document: self.pdfDocument) { data in
            
            onSave(data)
            dismiss()
            
        }
        
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
        
        HStack(spacing: 10) {
            
            ColorPicker("", selection: self.$selectedToolbarColor)
                .labelsHidden()
                .frame(width: 32, height: 32)
                .onChange(of: self.selectedToolbarColor) { _, new in
                    NotificationCenter.default.post(name: .pdfEditorColorChanged, object: UIColor(new))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: -12) {
                
                Text("Line Width")
                    .appFont(with: .TITLE_2)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
                ProgressSlider(value: self.$selectedToolbarLineWidth, thumbHeight: 24)
                    .frame(width: UIScreen.main.bounds.width * 0.33)
                    .onChange(of: self.selectedToolbarLineWidth) { _, new in
                        
                        let finalValue = Double(10 * new)
                        NotificationCenter.default.post(name: .pdfEditorWidthChanged, object: Double(finalValue))
                        
                    }
                
            }
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .offset(y: 5)
            
            Button {
                
                NotificationCenter
                    .default
                    .post(
                        name: .pdfEditorUndoRequest,
                        object: nil
                    )
                
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundStyle(Style.shared.accent.source())
            .appFont(with: .HEADER_1)
            
            Button {
                
                NotificationCenter
                    .default
                    .post(
                        name: .pdfEditorRedoRequest,
                        object: nil
                    )
                
            } label: {
                Image(systemName: "arrow.uturn.forward")
            }
            .foregroundStyle(Style.shared.accent.source())
            .appFont(with: .HEADER_1)
            
        }
        .padding(.small)
        
    }
    
    private func saveButton() -> some View {
        
        CommonButton(
            title: "Save"
        ) {
                
            NotificationCenter
                .default
                .post(
                    name: .pdfEditorSaveRequest,
                    object: nil
                )
 
        }
        
    }
    
}

#Preview {
    
    let url = Bundle.main.url(forResource: "PainDiagram", withExtension: "pdf")
    
    if let pdfURL = url,
       let pdfDocument = PDFDocument(url: pdfURL) {
        
        PDFEditorView(pdfDocument: pdfDocument) { editedData in
            print("Edited PDF size: \(editedData.count) bytes")
        }
        
    }
    
}
