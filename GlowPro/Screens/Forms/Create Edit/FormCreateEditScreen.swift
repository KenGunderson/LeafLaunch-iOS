//
//  FormCreateEditScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/7/25.
//

import SwiftUI
import PDFKit

struct FormCreateEditScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case title
        
        var displayName: String {
            switch self {
            case .title: return "Form Name"
            }
        }
        
    }
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: FormCreateEditViewModel
    @State private var phone: String = ""
    
    @FocusState private var focusedField: FocusedField?
        
    var body: some View {
        
        content()
        
        // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(navigationService: self.navigationService)
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
        
        // Tap
        
            .onSubmit {
                handleOnSubmit()
            }
        
            .onTapGesture {
                self.focusedField = nil
            }
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            contentCards()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        let deleteButton = NavBarButton(style: .trash) {
            
            self.viewModel
                .presentDeleteFormAlert()
            
        }
        .asAnyView()
        
        return NavBarView(
            title: self.viewModel.navTitle,
            leftButtonView: backButton,
            rightButtonView: self.viewModel.showDeleteButton ? deleteButton : nil
        )
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.large)) {
            
            formInformation()
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func formInformation() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            mediaURLPreview()
            textField(fieldToFocus: .title)
            
        }
        
    }
    
    private func textField(fieldToFocus: FocusedField) -> some View {
        
        var text: Binding<String> = .constant("")
        var isFocused: Bool = false
        var keyboardType: UIKeyboardType = .default
        var textContentType: UITextContentType = .organizationName
        
        let placeholder: String = fieldToFocus.displayName
        
        switch fieldToFocus {
        case .title:
            
            text = self.$viewModel.title
            isFocused = self.focusedField == .title
            keyboardType = .default
            textContentType = .organizationName
            
        }
        
        return TextField("", text: text)
            .titleUnderlineTextFieldStyle(
                text: text.wrappedValue,
                title: placeholder,
                style: .border(cornerRadius: .custom(6)),
                isFocused: isFocused,
                foregroundColor: Style.shared.textColor(.title),
                textFieldFont: .BODY_3
            )
            .focused(self.$focusedField, equals: fieldToFocus)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .submitLabel(.done)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .appOnTapGesture {
                self.focusedField = fieldToFocus
            }
        
    }
    
    @ViewBuilder
    private func mediaURLPreview() -> some View {
        
        let targetSize: CGFloat = 200
        
        if self.viewModel.isCreateContext {
            
            if let url = self.viewModel.url,
               let uiImage = makePDFPreviewImage(
                from: url,
                targetSize: .init(
                    width: targetSize,
                    height: targetSize
                )) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: targetSize,
                        height: targetSize + (targetSize * 0.40)
                    )
                    .clipped()
                    .contentShape(.rect)
                    .clipShape(.rect)
                    .cornerRadius(.small)
                    .appShadow(.card)
                
            }
            
        } else {
            
            if let url = self.viewModel.url {
                
                DownsampledRemoteImage(
                    url: url,
                    targetSize: .init(width: targetSize, height: targetSize),
                    contentMode: .fill,
                    placeholder: PlaceholderView().asAnyView()
                )
                .frame(
                    width: targetSize,
                    height: targetSize + (targetSize * 0.40)
                )
                .clipped()
                .contentShape(.rect)
                .clipShape(.rect)
                .cornerRadius(.small)
                .appShadow(.card)
                
            }
            
        }
        
    }
    
    private func handleOnSubmit() {
        
        var nextFocusedField: FocusedField? = nil
        
        switch self.focusedField {
        case .title: nextFocusedField = nil
        default: nextFocusedField = nil
        }
        
        self.focusedField = nextFocusedField
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if self.focusedField == nil {
            
            CommonButton(title: self.viewModel.saveButtonTitle,
                         isEnabled: self.viewModel.isSaveButtonEnabled) {
                
                self.viewModel
                    .saveOrUpdate()
                
            }
            .padding(.top, .small)
            .padding(.horizontal, .medium)
            .transition(.move(edge: .bottom)
                .combined(with: .opacity)
                .animation(.smooth(duration: 0.3))
            )
            .background(Style.shared.background(.primary).source())
            
        }
        
    }
    
    private func makePDFPreviewImage(from url: URL,
                                     targetSize: CGSize) -> UIImage? {
        
        guard let document = PDFDocument(url: url),
              let page = document.page(at: 0) else {
            return nil
        }
        
        let pageRect = page.bounds(for: .mediaBox)
        
        // Scale to fit targetSize while keeping aspect ratio
        let scale = min(targetSize.width  / pageRect.width,
                        targetSize.height / pageRect.height)
        
        let renderSize = CGSize(width: pageRect.width * scale,
                                height: pageRect.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(renderSize,
                                               false,
                                               0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        context.saveGState()
        
        // Flip coordinate system
        context.translateBy(x: 0, y: renderSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // Scale PDF page into our context
        context.scaleBy(x: scale, y: scale)
        
        page.draw(with: .mediaBox, to: context)
        
        context.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}

#Preview {
    
    let viewModel = mockResolve(FormCreateEditViewModel.self)
        .setup(
            formId: nil,
            url: GlowProForm.canvas.url
        )
    
    FormCreateEditScreen(viewModel: viewModel)
        .withMockServices()
    
}
