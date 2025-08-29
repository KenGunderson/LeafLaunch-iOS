//
//  ClientCreateEditScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/15/25.
//

import SwiftUI

struct ClientCreateEditScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case firstName
        case lastName
        case email
        case phone
        
        var displayName: String {
            switch self {
            case .firstName: return "First Name"
            case .lastName: return "Last Name"
            case .email: return "Email (Optional)"
            case .phone: return "Phone (Optional)"
            }
        }
        
    }
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: ClientCreateEditViewModel
    
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
        
        return NavBarView(
            title: self.viewModel.navTitle,
            leftButtonView: backButton
        )
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.large)) {
            
            businessGeneralInformation()
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func businessGeneralInformation() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "General Information")
            
            AppCardView {
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    textField(fieldToFocus: .firstName)
                    textField(fieldToFocus: .lastName)
                    textField(fieldToFocus: .email)
                    textField(fieldToFocus: .phone)
                    
                    dateOfBirthPicker()
                }
                
            }
            
        }
        
    }
    
    private func textField(fieldToFocus: FocusedField) -> some View {
        
        var text: Binding<String> = .constant("")
        var isFocused: Bool = false
        var keyboardType: UIKeyboardType = .default
        var textContentType: UITextContentType = .organizationName
        
        let placeholder: String = fieldToFocus.displayName
        
        switch fieldToFocus {
        case .firstName:
            
            text = self.$viewModel.firstName
            isFocused = self.focusedField == .firstName
            keyboardType = .default
            textContentType = .organizationName
            
        case .lastName:
            
            text = self.$viewModel.lastName
            isFocused = self.focusedField == .lastName
            keyboardType = .default
            textContentType = .organizationName
            
        case .email:
            
            text = self.$viewModel.email
            isFocused = self.focusedField == .email
            keyboardType = .emailAddress
            textContentType = .emailAddress
            
        case .phone:
            
            text = self.$viewModel.phone
            isFocused = self.focusedField == .phone
            keyboardType = .phonePad
            textContentType = .telephoneNumber
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
    private func dateOfBirthPicker() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Date Of Birth (Optional)")
            
            DatePicker(
                "",
                selection: self.$viewModel.dateOfBirth,
                displayedComponents: .date
            )
            .tint(Style.shared.accent.source())
            .datePickerStyle(.compact)
            .fixedSize()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, -8)
            
        }
        .foregroundStyle(Style.shared.textColor(.title).source())
        .appFont(with: .TITLE_3)
        .padding(.top, Style.shared.spacing(.extraSmall))
        .preferredColorScheme(.light)
        
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
    
    let viewModel = mockResolve(ClientCreateEditViewModel.self)
        .setup(locationId: MockModels.ID.location1)
    
    ClientCreateEditScreen(viewModel: viewModel)
        .withMockServices()
    
}
