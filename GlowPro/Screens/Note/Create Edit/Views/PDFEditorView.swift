//
//  PDFEditorView.swift
//  GlowPro
//
//  Created by Kenneth Gunderson on 10/25/25.
//

import SwiftUI
import PDFKit
import PencilKit
import UniformTypeIdentifiers

struct PDFEditorView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let onSave: (Data) -> Void
    let pdfItems: [URL]

    @State private var selectedIndex: Int = 0
    @State private var currentDoc: PDFDocument?
    @State private var width: CGFloat = 2.5
    @State private var color: Color = .black

    init(pdfItems: [URL], onSave: @escaping (Data) -> Void) {
        
        self.pdfItems = pdfItems
        self.onSave = onSave
        
        _currentDoc = State(initialValue: pdfItems.first.flatMap { PDFDocument(url: $0) })
        
    }
    
    var body: some View {
        
        content()
        
    }
    
    private func content() -> some View {
     
        AppBaseView() {
            buildPDFView()
        }
        .safeAreaInset(edge: .top) {
            navBar()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    private func buildPDFView() -> some View {
        
        ZStack(alignment: .top) {
            
            if let doc = currentDoc {
                
//                PDFKitCanvasView(document: doc) { mergedData in
//                    
//                    onSave(mergedData)
//                    dismiss()
//                    
//                }
//                .overlay(alignment: .topTrailing) {
//                    
//                    toolBar()
//                    
//                }
                
                PDFInkView(document: doc) { data in
                    
                    onSave(data)
                    dismiss()
                    
                }
                .overlay(alignment: .topTrailing) {
                    
                    toolBar()
                    
                }
                
            } 
            
        }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            pdfOptionsList()
                .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
            
            saveButton()
                .padding(.horizontal, .medium)
            
        }
        .background(Style.shared.background(.primary).source())
        
    }
    
    @ViewBuilder
    private func pdfOptionsList() -> some View {
        
        ScrollViewReader { proxy in
            
            ScrollView(.horizontal) {
                
                HStack(spacing: Style.shared.spacing(.custom(2))) {
                    
                    ForEach(pdfItems.indices, id: \.self) { pdf in
                        
                        PDFThumbnailView(
                            url: pdfItems[pdf],
                            size: CGSize(width: 65, height: 65)
                        )
                            .clipped()
                            .appBorder(
                                cornerRadius: .small,
                                color: pdf == selectedIndex ?.color(GPColor.green) : Style.shared.background(.quaternary),
                                lineWidth: 3,
                                outerBorder: false
                            )
                            .onTapGesture {
                                selectedIndex = pdf
                            }
                        
                    }
                    
                }
                .scrollTargetLayout()
                
            }
            .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
            .scrollTargetBehavior(.viewAligned(limitBehavior: .never))
            .padding(.top, .medium)
            .background(Style.shared.background(.primary).source())
            .ignoresSafeArea()
            .onAppear {
                
                withAnimation(.bouncy) {
                    proxy.scrollTo(self.selectedIndex, anchor: .center)
                }
                
            }
            .onChange(of: self.selectedIndex) { _, newValue in
                
                withAnimation(.bouncy) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
                
            }
            
        }
        .overlay(alignment: .top) {
            
            Rectangle()
                .fill(Style.shared.background(.quaternary).source())
                .frame(height: 1)
            
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        
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
    
    private func toolBar() -> some View {
        
        HStack(spacing: 10) {
            
            ColorPicker("", selection: $color)
                .labelsHidden()
                .frame(width: 32, height: 32)
                .onChange(of: color) { _, new in
                    NotificationCenter.default.post(name: .pdfEditorColorChanged, object: UIColor(new))
                }
            
            Slider(value: $width, in: 0.5...10, step: 0.5)
                .frame(width: 120)
                .onChange(of: width) { _, new in
                    NotificationCenter.default.post(name: .pdfEditorWidthChanged, object: new as CGFloat)
                }
            
            Button {
                NotificationCenter.default.post(name: .pdfEditorUndoRequest, object: nil)
            } label: { Image(systemName: "arrow.uturn.backward") }

            Button {
                NotificationCenter.default.post(name: .pdfEditorRedoRequest, object: nil)
            } label: { Image(systemName: "arrow.uturn.forward") }
            
        }
        .padding(10)
        .background(.ultraThinMaterial, in: Capsule())
        .padding()
        
    }
    
    private func saveButton() -> some View {
        
        CommonButton(
            title: "Save"
        ) {
                
            NotificationCenter.default.post(name: .pdfEditorSaveRequest, object: nil)
                
        }
        
    }
    
    func drawPDFfromURL(url: URL) -> UIImage? {
      guard
      let document = CGPDFDocument(url as CFURL)
      else {
        return nil
      }
      guard
      let page = document.page(at: 1)
      else {
        return nil
      }

      let pageRect = page.getBoxRect(.mediaBox)
      let renderer = UIGraphicsImageRenderer(size: pageRect.size)
      let img = renderer.image {
        ctx in
          UIColor.clear.set()
        ctx.fill(pageRect)

        ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

        ctx.cgContext.drawPDFPage(page)
      }

      return img
    }
    
}

#Preview {
    
    if let pdfURL = Bundle.main.url(forResource: "PainDiagram", withExtension: "pdf") {
        
        PDFEditorView(pdfItems: [pdfURL, pdfURL, pdfURL]) { editedData in
            print("Edited PDF size: \(editedData.count) bytes")
        }
        
    } else {
        
        Text("⚠️ Missing PainDiagram.pdf in bundle.")
            .font(.headline)
            .padding()
        
    }
    
}
