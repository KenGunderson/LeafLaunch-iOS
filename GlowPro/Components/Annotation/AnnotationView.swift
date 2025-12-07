//
//  AnnotationView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 12/3/25.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct AnnotationView: View {

    @Environment(\.dismiss) private var dismiss

    private let kind: AnnotationKind
    private let isReadOnly: Bool
    private let onSave: (Data) -> Void

    @State private var isDrawing: Bool = false
    @State private var controller = PDFController()
    @State private var toolPickerFrame: CGRect = .zero
    
    var navTitle: String {
        
        var prefix = ""
        let suffix = self.isReadOnly ? "Preview" : "Editor"
        
        switch self.kind {
        case .url: prefix = "Media"
        case .pdf: prefix = "PDF"
        }
        
        return "\(prefix) \(suffix)"
        
    }

    init(kind: AnnotationKind,
         isReadOnly: Bool = false,
         onSave: @escaping (Data) -> Void) {

        self.kind = kind
        self.isReadOnly = isReadOnly
        self.onSave = onSave

    }

    var body: some View {
        content()
    }

    private func content() -> some View {

        AppBaseView {
            annotationView()
        }
        .safeAreaInset(edge: .top) {
            navBar()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        .onAppear {
            
            self.controller
                .setDrawingEnabled(false)

            self.controller.onToolPickerFrameChange = { frame in
                
                withAnimation(.easeOut(duration: 0.25)) {
                    self.toolPickerFrame = frame
                }
                
            }

        }

    }

    private func navBar() -> some View {

        let backButton = NavBarButton(style: .close) {
            self.dismiss()
        }
        .asAnyView()

        return NavBarView(
            title: self.navTitle,
            subtitle: nil,
            leftButtonView: backButton,
            divider: .init(
                shouldShow: true,
                lineWidth: 1,
            ),
        )

    }

    @ViewBuilder
    private func annotationView() -> some View {

        switch self.kind {
        case .url(let url):
            
            PhotoEditor(
                imageURL: url,
                controller: self.controller
            )
            .frame(maxHeight: .infinity, alignment: .center)
            .if(self.isReadOnly) { view in
                view.ignoresSafeArea(edges: .bottom)
            }
            
        case .pdf(let pdfDocument):
            
            PDFEditor(
                document: pdfDocument,
                controller: self.controller
            )
            .frame(maxHeight: .infinity)
            .if(self.isReadOnly) { view in
                view.ignoresSafeArea(edges: .bottom)
            }
            
        }

    }

    @ViewBuilder
    private func bottomBar() -> some View {
        
        if !self.isReadOnly {
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                toolBar()
                    .compositingGroup()
                    .geometryGroup()
                    .padding(.bottom, self.isDrawing ? self.toolPickerFrame.height + 32 : 0)
                
                saveButton()
                
            }
            .padding(.horizontal, .medium)
            .frame(maxWidth: .infinity)
            .background(Style.shared.background(.primary).source())
            .animation(.easeOut(duration: 0.2), value: self.toolPickerFrame)
            .animation(.easeOut(duration: 0.2), value: self.isDrawing)
            
        }

    }

    private func toolBar() -> some View {

        VStack {

            HStack {

                toolItem()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                
                undoRedo()
                
            }

        }
        .padding(.small)

    }

    @ViewBuilder
    private func toolItem() -> some View {
        
        let isSelected = self.isDrawing

        let title = "Annotate"
        let icon: ImageSource = .systemImage("pencil")
        
        let backgroundStyle = isSelected
            ? Style.shared.accent
            : Style.shared.background(.quaternary)

        let foregroundStyle = isSelected
            ? Style.shared.textColor(.button)
            : Style.shared.textColor(.title)

        HStack {
            
            icon
                .view()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            
            Text(title)
                .appFont(with: .TITLE_3)
            
        }
        .foregroundStyle(foregroundStyle.source())
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(backgroundStyle.source())
        .clipShape(.capsule)
        .asButton {

            self.isDrawing = !isSelected
            self.controller.setDrawingEnabled(!isSelected)

        }

    }

    @ViewBuilder
    private func undoRedo() -> some View {

        HStack {

            Button {

                self.controller.undo()

            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .foregroundStyle(Style.shared.accent.source())
            .appFont(with: .HEADER_1)

            Button {

                self.controller.redo()

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

            let savedData = self.controller.snapshot()
            self.onSave(savedData)
            
            dismiss()

        }

    }

}

#Preview("PDF Annotation") {
    
    let url = Bundle.main.url(forResource: "Sample", withExtension: "pdf")!
    let pdfDoucment = PDFDocument(url: url)!
    
    AnnotationView(kind: .pdf(pdfDoucment)) { editedData in
        print("Edited PDF size: \(editedData.count) bytes")
    }
    
}

#Preview("URL Annotation") {
    
    let url = MockModels.allMedia[15].url
    
    AnnotationView(kind: .url(url)) { editedData in
        print("Edited PDF size: \(editedData.count) bytes")
    }
    
}
