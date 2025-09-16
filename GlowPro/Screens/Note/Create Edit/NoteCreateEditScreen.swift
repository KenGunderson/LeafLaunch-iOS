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
        
        var displayName: String {
            switch self {
            case .title: return "Title"
            case .note: return "Note"
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
        
            .onTapGesture {
                self.focusedField = nil
            }
        
        // Animation
        
            .animation(.smooth, value: self.focusedField)
        
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
            
            textField()
            textEditField()
            
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
    
    private func textField() -> some View {
        
        let text = self.$viewModel.title
        let isFocused = self.focusedField == .title
        let keyboardType: UIKeyboardType = .default
        
        return TextField("", text: text)
            .titleUnderlineTextFieldStyle(
                text: text.wrappedValue,
                title: FocusedField.title.displayName,
                style: .border(cornerRadius: .custom(6)),
                isFocused: isFocused,
                foregroundColor: Style.shared.textColor(.title),
                textFieldFont: .BODY_3
            )
            .focused(self.$focusedField, equals: .title)
            .keyboardType(keyboardType)
            .submitLabel(.done)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .appOnTapGesture {
                self.focusedField = .title
            }
        
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
                
                ForEach(self.viewModel.mediaURLs, id: \.self) { url in
                    mediaItem(url)
                }
                
                cameraItem()
                
            }
            .padding(.top, .small)
            
        }
        
    }
    
    private func saveButton() -> some View {
        
        CommonButton(
            title: self.viewModel.saveButtonTitle,
            isEnabled: self.viewModel.isSaveButtonEnabled) {
                
                self.viewModel
                    .saveOrUpdate()
                
            }
        
    }
    
    private func mediaItem(_ url: URL) -> some View {
        
        ImageSource
            .remote(url: url, placeholder: PlaceholderView().asAnyView())
            .view()
            .frame(width: 75, height: 75)
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
                        print("Attempt to remove media: \(url)")
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
            .appBorder(
                cornerRadius: .small,
                color: Style.shared.background(.quaternary),
                lineWidth: 3,
                outerBorder: false
            )
            .cornerRadius(.custom(9))
            .background(.backgroundTappable)
            .asButton {}
        
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
