//
//  NoteCreateEditScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/13/25.
//

import SwiftUI

struct NoteCreateEditScreen: View {
    
    enum FocusedField: Hashable {
        
        case title
        case note
        case signiture
        
        var displayName: String {
            switch self {
            case .title: return "Title"
            case .note: return "Note"
            case .signiture: return "Employee Signiture (Full Name)"
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
        
        // Sheet
        
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
                .presentationCompactAdaptation(.popover)
                
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
    
    private func fields() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            textField(.title)
            textEditField()
            
            textField(.signiture)
                .allowsHitTesting(self.viewModel.isOwnerOrManager)
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func textEditField() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.custom(6))) {
            
            Text("Note")
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            CommonTextEditView(
                text: self.$viewModel.message,
                placehoderText: "...",
                isFocused: self.focusedField == .note,
                titleFont: .BODY_3,
                unselectedBorderColor: .color(.clear),
                backgroundStyle: .color(.clear),
                cornerRadius: .small,
                shadow: .none,
                lineLimit: 5...20,
                verticalPadding: .small,
                horizontalPadding: .small
            )
            .focused(self.$focusedField, equals: .note)
            .appBorder(cornerRadius: .small, lineWidth: 1)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
              
        }
        
    }
    
    private func textField(_ focusedField: FocusedField) -> some View {
        
        let isSignitureEnabled = (self.viewModel.isOwnerOrManager)
        var backgroundColor: ColorSource {
            
            if focusedField == .signiture {
                return isSignitureEnabled ? .color(.clear) : Style.shared.background(.quaternary)
            }
            
            return .color(.clear)
            
        }
        
        let text: Binding<String> = (focusedField == .title) ? self.$viewModel.title : self.$viewModel.employeeSignature
        let isFocused = self.focusedField == focusedField
        let keyboardType: UIKeyboardType = .default
        
        return TextField("", text: text)
            .titleUnderlineTextFieldStyle(
                text: text.wrappedValue,
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
            .allowsHitTesting(focusedField == .signiture ? isSignitureEnabled : true)
        
    }
    
    private func handleOnSubmit() {
        
        var nextFocusedField: FocusedField? = nil
        
        switch self.focusedField {
        case .title: nextFocusedField = .note
        case .note:
            
            let isOwnerOrManager = self.viewModel.isOwnerOrManager
            nextFocusedField = isOwnerOrManager ? .signiture : nil
            
        case .signiture: nextFocusedField = nil
        default: nextFocusedField = nil
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
        }
        
    }
    
    private func urlItem(url: URL,
                         mediaFusion: MediaFusion) -> some View {
        
        ImageSource
            .remote(url: url, placeholder: PlaceholderView().asAnyView())
            .view()
            .frame(width: 75, height: 75)
            .background(Style.shared.background(.primary).source())
            .appBorder(
                cornerRadius: .small,
                color: Style.shared.accent,
                lineWidth: 3,
                outerBorder: false
            )
            .cornerRadius(.custom(9))
            .overlay(alignment: .topTrailing) {
                
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(AnyShapeStyle(Color.white), Style.shared.background(.error).source())
                    .asButton {
                        
                        self.viewModel
                            .deleteMediaFusion(id: mediaFusion.id)
                        
                    }
                    .offset(x: 8, y: -8)
                
            }
            .asButton {
             
                self.navigationService
                    .modal(fullScreenCover: .mediaPreview(url: url))
                
            }
        
    }
    
    private func appleMediaItem(uiImage: UIImage,
                                mediaFusion: MediaFusion) -> some View {
        
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 75, height: 75)
            .background(Style.shared.background(.primary).source())
            .appBorder(
                cornerRadius: .small,
                color: Style.shared.accent,
                lineWidth: 3,
                outerBorder: false
            )
            .cornerRadius(.custom(9))
            .overlay(alignment: .topTrailing) {
                
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(AnyShapeStyle(Color.white), Style.shared.background(.error).source())
                    .asButton {
                        
                        self.viewModel
                            .deleteMediaFusion(id: mediaFusion.id)
                        
                    }
                    .offset(x: 8, y: -8)
                
            }
        
    }
    
    private func cameraItem() -> some View {
        
        Image(systemName: "camera.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Style.shared.background(.quaternary).source())
            .padding(.large)
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
            .asButton {
                
                self.viewModel
                    .shouldShowMediaSourceSelectionSheet = true
                
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
