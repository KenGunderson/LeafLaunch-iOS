//
//  FormCreateEditScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/7/25.
//

import SwiftUI

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
        
        if let url = self.viewModel.url {
            
            DownsampledRemoteImage(
                url: url,
                targetSize: .init(width: 200, height: 240),
                contentMode: .fill,
                placeholder: PlaceholderView().asAnyView()
            )
            .scaledToFill()
            .frame(
                width: 200,
                height: 240
            )
            .clipped()
            .contentShape(.rect)
            .clipShape(.rect)
            .cornerRadius(.small)
            .appShadow(.card)
            
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
    
}

#Preview {
    
    let viewModel = mockResolve(FormCreateEditViewModel.self)
        .setup(
            formId: nil,
            url: MockModels.allForms.first?.mediaURL
        )
    
    FormCreateEditScreen(viewModel: viewModel)
        .withMockServices()
    
}
