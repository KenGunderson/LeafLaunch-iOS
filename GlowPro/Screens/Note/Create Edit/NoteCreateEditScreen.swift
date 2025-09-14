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
            
            CommonButton(
                title: self.viewModel.saveButtonTitle,
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
    
}

#Preview {
    
    let viewModel = mockResolve(NoteCreateEditViewModel.self)
        .setup(
            context: .create,
            clientId: MockModels.ID.client1
        )
    
    NoteCreateEditScreen(
        viewModel: viewModel
    )
    .withMockServices()
    
}
