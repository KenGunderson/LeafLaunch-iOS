//
//  NoteCreateEditScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/13/25.
//

import SwiftUI
import PDFKit

struct NoteCreateEditScreen: View {
    
    enum FocusedField: Hashable {
        
        case title
        case note
        case signature
        
        case treatmentType
        case sessionNumber
        case productDeviceUsed
        case dosage
        case treatmentNotes
        case outcome
        case treatedBy
        case reviewedBy
        
        case soapS
        case soapO
        case soapA
        case soapP
        
        var displayName: String {
            
            switch self {
            case .title: return "Title"
            case .note: return "Note"
            case .signature: return "Employee Signature (Full Name)"
                
            case .treatmentType: return "Treatment Type"
            case .sessionNumber: return "Session Number"
            case .productDeviceUsed: return "Product/Device Used"
            case .dosage: return "Dosage"
            case .treatmentNotes: return "Treatment Notes"
            case .outcome: return "Outcome"
            case .treatedBy: return "Treated By"
            case .reviewedBy: return "Reviewed By"
                
            case .soapS: return "Subjective"
            case .soapO: return "Objective"
            case .soapA: return "Assessment"
            case .soapP: return "Plan"
            }
            
        }
        
    }
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: NoteCreateEditViewModel
    
    @FocusState private var focusedField: FocusedField?
    
    init(viewModel: NoteCreateEditViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
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
        
        // Media Sheet
        
            .adaptiveSheet(
                isPresented: self.$viewModel.shouldShowMediaSourceSelectionSheet,
                additionalDetens: [],
                backgroundStyle: Style.shared.background(.primary)
            ) {
                
                MediaSourceSelectionView(selectedSourceTypeAction: { source in
                    self.viewModel.handleSourceSelectionAction(source)
                })
                .frame(maxWidth: .infinity)
                .presentationCornerRadius(Style.shared.radius(.large))
                .presentationCompactAdaptation(.sheet)
                
            }
        
            .photosPicker(
                isPresented: self.$viewModel.shouldShowApplePhotosSelectionSheet,
                selection: self.$viewModel.selectedPhotoPickerItems,
                maxSelectionCount: 5,
                selectionBehavior: .ordered,
                matching: .images
            )
        
        // OnChange
        
            .onChange(of: self.viewModel.selectedPhotoPickerItems) { _, newValue in
                
                self.viewModel
                    .handlePHPickerSelectionConverionToUIImage(items: newValue)
                
            }
        
        // Animation
        
            .animation(.smooth, value: self.focusedField)
            .animation(.smooth, value: self.viewModel.mediaFusion)
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            fields()
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
        
        let trashButton = NavBarButton(style: .trash) {
            
            self.viewModel
                .presentDeleteNoteAlert()
            
        }
        .asAnyView()
        
        let shouldShowTrashButton = self.viewModel.isEditContext && self.viewModel.isOwnerOrManager
        
        return NavBarView(
            title: self.viewModel.navTitle,
            leftButtonView: backButton,
            rightButtonView: shouldShowTrashButton ? trashButton : nil
        )
        
    }
    
    @ViewBuilder
    private func fields() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            if let noteType = self.viewModel.noteType {
                
                Text(noteType.longDisplayName)
                    .appFont(with: .HEADER_2)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .padding(.horizontal, .medium)
                
            }
            
            switch self.viewModel.noteType {
            case .quick: quickEditFields()
            case .soap: soapFields()
            case .advanced: advancedFields()
            default: EmptyView()
            }
            
        }
        .frameInfinity()
        
    }
    
    private func quickEditFields() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            textField(.title)
            textEditField(.note)
            
            textField(.signature)
                .allowsHitTesting(self.viewModel.isOwnerOrManager)
            
        }
        .frameInfinity()
        .padding(.horizontal, .medium)
        
    }
    
    private func soapFields() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            textField(.title)
            
            textEditField(.soapS)
            textEditField(.soapO)
            textEditField(.soapA)
            textEditField(.soapP)
            
        }
        .frameInfinity()
        .padding(.horizontal, .medium)
        
    }
    
    private func advancedFields() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            textField(.title)
            
            HStack {
                
                textField(.treatmentType)
                textField(.sessionNumber)
                
            }
            
            textField(.dosage)
            textEditField(.productDeviceUsed)
            textEditField(.treatmentNotes)
            textEditField(.outcome)
            
            HStack {
                
                textField(.treatedBy)
                textField(.reviewedBy)
                
            }
            
        }
        .frameInfinity()
        .padding(.horizontal, .medium)
        
    }
    
    private func textEditField(_ focusedField: FocusedField) -> some View {
        
        var binding: Binding<String> {
            switch focusedField {
            case .note: return self.$viewModel.message
            case .soapS: return self.$viewModel.soapS
            case .soapO: return self.$viewModel.soapO
            case .soapA: return self.$viewModel.soapA
            case .soapP: return self.$viewModel.soapP
            case .treatmentNotes: return self.$viewModel.treatmentNotes
            case .productDeviceUsed: return self.$viewModel.productDeviceUsed
            case .outcome: return self.$viewModel.outcome
            default: return .constant("")
            }
        }
        
        var numberOfLinesStarting: Int {
            switch focusedField {
            case .note: return 5
            case .soapS: return 3
            case .soapO: return 3
            case .soapA: return 3
            case .soapP: return 3
            case .treatmentNotes: return 3
            case .productDeviceUsed: return 3
            case .outcome: return 3
            default: return 5
            }
        }
        
        return VStack(alignment: .leading, spacing: Style.shared.spacing(.custom(6))) {
            
            Text(focusedField.displayName)
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            CommonTextEditView(
                text: binding,
                placehoderText: "...",
                isFocused: self.focusedField == focusedField,
                titleFont: .BODY_3,
                unselectedBorderColor: .color(.clear),
                backgroundStyle: .color(.clear),
                cornerRadius: .small,
                shadow: .none,
                lineLimit: numberOfLinesStarting...20,
                verticalPadding: .small,
                horizontalPadding: .small
            )
            .focused(self.$focusedField, equals: focusedField)
            .appBorder(cornerRadius: .small, lineWidth: 1)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
              
        }
        
    }
    
    private func textField(_ focusedField: FocusedField) -> some View {
        
        let isSignatureEnabled = (self.viewModel.isOwnerOrManager)
        var backgroundColor: ColorSource {
            
            if focusedField == .signature {
                return isSignatureEnabled ? .color(.clear) : Style.shared.background(.quaternary)
            }
            
            return .color(.clear)
            
        }
                
        var binding: Binding<String> {
            switch focusedField {
            case .title: return self.$viewModel.title
            case .signature: return self.$viewModel.employeeSignature
            case .treatmentType: return self.$viewModel.treatmentType
            case .sessionNumber: return self.$viewModel.sessionNumber
            case .dosage: return self.$viewModel.dosage
            case .treatedBy: return self.$viewModel.treatedBy
            case .reviewedBy: return self.$viewModel.reviewedBy
            default: return .constant("")
            }
        }
        
        let isFocused = self.focusedField == focusedField
        let keyboardType: UIKeyboardType = .default
        
        return TextField("", text: binding)
            .titleUnderlineTextFieldStyle(
                text: binding.wrappedValue,
                title: focusedField.displayName,
                style: .border(cornerRadius: .custom(6)),
                isFocused: isFocused,
                foregroundColor: Style.shared.textColor(.title),
                backgroundColor: backgroundColor,
                textFieldFont: .BODY_3
            )
            .focused(self.$focusedField, equals: focusedField)
            .keyboardType(keyboardType)
            .submitLabel(.done)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .appOnTapGesture {
                self.focusedField = focusedField
            }
            .allowsHitTesting(focusedField == .signature ? isSignatureEnabled : true)
        
    }
    
    private func handleOnSubmit() {
        
        var nextFocusedField: FocusedField? = nil
        
        switch self.viewModel.noteType {
        case .quick:
            
            switch self.focusedField {
            case .title: nextFocusedField = .note
            case .note:
                
                let isOwnerOrManager = self.viewModel.isOwnerOrManager
                nextFocusedField = isOwnerOrManager ? .signature : nil
                
            case .signature: nextFocusedField = nil
            default: nextFocusedField = nil
            }
            
        case .soap:
            
            switch self.focusedField {
            case .title: nextFocusedField = .soapS
            case .soapS: nextFocusedField = .soapO
            case .soapO: nextFocusedField = .soapA
            case .soapA: nextFocusedField = .soapP
            case .soapP: nextFocusedField = nil
            default: nextFocusedField = nil
            }
            
        case .advanced:
            
            switch self.focusedField {
            case .title: nextFocusedField = .treatmentType
            case .treatmentType: nextFocusedField = .sessionNumber
            case .sessionNumber: nextFocusedField = .productDeviceUsed
            case .productDeviceUsed: nextFocusedField = .dosage
            case .dosage: nextFocusedField = .treatmentNotes
            case .treatmentNotes: nextFocusedField = .outcome
            case .outcome: nextFocusedField = .treatedBy
            case .treatedBy: nextFocusedField = .reviewedBy
            case .reviewedBy: nextFocusedField = nil
            default: nextFocusedField = nil
            }
            
        case .none: break
        }
        
        self.focusedField = nextFocusedField
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if self.focusedField == nil {
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                mediaList()
                    .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
                
                saveButton()
                    .padding(.horizontal, .medium)
                
            }
            .background(Style.shared.background(.primary).source())
            .transition(.move(edge: .bottom)
                .combined(with: .opacity)
                .animation(.smooth(duration: 0.3))
            )
            
        }
        
    }
    
    private func mediaList() -> some View {
            
        ScrollView(.horizontal) {
            
            HStack {
                
                ForEach(self.viewModel.mediaFusion, id: \.id) { item in
                    mediaItem(item)
                }
                
                cameraItem()
                
                documentItem()
                
            }
            .padding(.top, .small)
            
        }
        .scrollIndicators(.hidden)
        
    }
    
    private func saveButton() -> some View {
        
        CommonButton(
            title: self.viewModel.saveButtonTitle,
            isEnabled: self.viewModel.isSaveButtonEnabled) {
                
                self.viewModel
                    .saveOrUpdate()
                
            }
        
    }
    
    @ViewBuilder
    private func mediaItem(_ mediaFusion: MediaFusion) -> some View {
        
        switch mediaFusion.kind {
            
        case .url(let url): urlItem(url: url, mediaFusion: mediaFusion)
        case .uiImage(let image): appleMediaItem(uiImage: image, mediaFusion: mediaFusion)
        case .pdf(let data): pdfMediaItem(pdfData: data, mediaFusion: mediaFusion)
        }
        
    }
    
    @ViewBuilder
    private func urlItem(url: URL,
                         mediaFusion: MediaFusion) -> some View {
        
        let imageView = DownsampledRemoteImage(
            url: url,
            targetSize: .init(width: 75, height: 75),
            contentMode: .fill,
            placeholder: PlaceholderView().asAnyView()
        )
            .asAnyView()
        
        mediaItem(
            imageSource: imageView,
            deleteAction: {
                
                self.viewModel
                    .deleteMediaFusion(id: mediaFusion.id)
                
            },
            action: {
                
                self.navigationService
                    .modal(fullScreenCover: .mediaPreview(context: .url(url: url)))
                
            }
        )
        
    }
    
    private func appleMediaItem(uiImage: UIImage,
                                mediaFusion: MediaFusion) -> some View {
        
        mediaItem(
            image: Image(uiImage: uiImage),
            deleteAction: {
                
                self.viewModel
                    .deleteMediaFusion(id: mediaFusion.id)
                
            },
            action: {
                
                self.navigationService
                    .modal(fullScreenCover: .mediaPreview(context: .uiImage(uiImage: uiImage)))
                
            }
        )
        
    }
    
    private func pdfMediaItem(pdfData: Data,
                                mediaFusion: MediaFusion) -> some View {
        
        mediaItem(
            image: Image(uiImage: mediaFusion.kind.image ?? UIImage(systemName: "photo.badge.exclamationmark.fill")!),
            deleteAction: {
                
                self.viewModel
                    .deleteMediaFusion(id: mediaFusion.id)
                
            },
            action: {
                
                if let pdfDoc = PDFDocument(data: pdfData) {
                    
                    self.navigationService
                        .modal(fullScreenCover: .pdfEditor(pdfDocument: pdfDoc) { data in
                            
                            self.viewModel
                                .removeOldPDFMediaFusion(mediaFusion: mediaFusion)
                            
                            self.viewModel
                                .handlePDFDocumentSelection(data: data)
                            
                        })
                    
                }
                
            }
        )
        
    }
    
    private func cameraItem() -> some View {
        
        mediaItem(
            image: Image(systemName: "camera.fill"),
            contentMode: .fit,
            systemImagePadding: Style.shared.spacing(.large),
            deleteAction: nil,
            action: {
                
                self.viewModel
                    .shouldShowMediaSourceSelectionSheet = true
                
            }
        )
        
    }
    
    private func documentItem() -> some View {
        
        mediaItem(
            image: Image(systemName: "heart.text.clipboard.fill"),
            contentMode: .fit,
            systemImagePadding: Style.shared.spacing(.large),
            deleteAction: nil,
            action: {
                
                // TODO: - REMOVE THIS WHEN WE HAVE REAL DIAGRAMS
                if let pdfURL = Bundle.main.url(forResource: "PainDiagram", withExtension: "pdf"),
                   let pdfDoc = PDFDocument(url: pdfURL) {
                    
                    self.navigationService
                        .modal(fullScreenCover: .pdfEditor(pdfDocument: pdfDoc) { data in
                            
                            self.viewModel
                                .handlePDFDocumentSelection(data: data)
                            
                        })
                    
                }
                
            }
        )
        
    }
    
    private func mediaItem(image: Image? = nil,
                           imageSource: AnyView? = nil,
                           aspectRatio: CGFloat? = nil,
                           contentMode: ContentMode = .fill,
                           systemImagePadding: CGFloat = 0,
                           deleteAction: (() -> ())?,
                           action: @escaping () -> ()) -> some View {
        
        Group {
            
            if let image {
                
                image
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: contentMode)
                
            } else if let imageSource {
                imageSource
            }
            
        }
        .foregroundStyle(Style.shared.background(.quaternary).source())
        .padding(systemImagePadding)
        .frame(width: 75, height: 75)
        .background(Style.shared.background(.primary).source())
        .appBorder(
            cornerRadius: .small,
            color: Style.shared.background(.quaternary),
            lineWidth: 3,
            outerBorder: false
        )
        .cornerRadius(.custom(9))
        .background(.backgroundTappable)
        .if(deleteAction != nil) { view in
            
            view.overlay(alignment: .topTrailing) {
                
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(AnyShapeStyle(Color.white), Style.shared.background(.error).source())
                    .asButton {
                        
                        deleteAction?()
                        
                    }
                    .offset(x: 8, y: -8)
                
            }
            
        }
        .asButton {
            action()
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(NoteCreateEditViewModel.self)
        .setup(
            context: .update(noteId: MockModels.MockNote.note1.id),
            clientId: MockModels.ID.client1
        )
    
    NoteCreateEditScreen(
        viewModel: viewModel
    )
    .withMockServices()
    
}
