//
//  ProfileScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/28/25.
//

import SwiftUI
import Charts

struct ProfileScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case firstName
        case lastName
        case email
        
        var displayName: String {
            switch self {
            case .firstName: return "First Name"
            case .lastName: return "Last Name"
            case .email: return "Email (Uneditable)"
            }
        }
        
    }

    @Environment(NavigationService.self) private var navigationService

    @StateObject var viewModel: ProfileViewModel
    
    @FocusState private var focusedField: FocusedField?
                
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            headerView()
        } scrollViewContent: {
            content()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
        // Lifecycle
        
        .onFirstAppear {
            
            self.viewModel
                .loadData()
            
            self.viewModel
                .handleFirstAppear()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }
        
        // Tap
    
        .onSubmit {
            handleOnSubmit()
        }
    
        .onTapGesture {
            self.focusedField = nil
        }

    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "Profile",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        let config = Constants.StaggerAnimation.config(interitemSpacing: 16)
        
        StaggeredView(config: config) {
            
            if !self.viewModel.isLoading {
                
                textField(fieldToFocus: .firstName)
                textField(fieldToFocus: .lastName)
                textField(fieldToFocus: .email)
                dateOfBirthPicker()
                
            }
            
        }
        .padding(.top, .small)
        
    }
    
    private func textField(fieldToFocus: FocusedField) -> some View {
        
        var text: Binding<String> = .constant("")
        var isFocused: Bool = false
        var keyboardType: UIKeyboardType = .default
        var textContentType: UITextContentType = .name
        
        let placeholder: String = fieldToFocus.displayName
        
        switch fieldToFocus {
        case .firstName:
            
            text = self.$viewModel.firstName
            isFocused = self.focusedField == .firstName
            keyboardType = .default
            textContentType = .givenName
            
        case .lastName:
            
            text = self.$viewModel.lastName
            isFocused = self.focusedField == .lastName
            keyboardType = .default
            textContentType = .familyName
            
        case .email:
            
            text = self.$viewModel.email
            isFocused = self.focusedField == .email
            keyboardType = .default
            textContentType = .emailAddress
        }
        
        return TextField("", text: text)
            .titleUnderlineTextFieldStyle(
                text: text.wrappedValue,
                title: placeholder,
                style: .border(cornerRadius: .custom(6)),
                isFocused: isFocused,
                foregroundColor: Style.shared.textColor(.title),
                backgroundColor: fieldToFocus == .email ? Style.shared.background(.quaternary) : .color(.clear),
                textFieldFont: .BODY_3
            )
            .focused(self.$focusedField, equals: fieldToFocus)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .appOnTapGesture {
                self.focusedField = fieldToFocus
            }
            .allowsHitTesting(fieldToFocus != .email)
        
    }
    
    private func handleOnSubmit() {
        
        var nextFocusedField: FocusedField? = nil
        
        switch self.focusedField {
        case .firstName: nextFocusedField = .lastName
        case .lastName: nextFocusedField = nil
        default: nextFocusedField = nil
        }
        
        self.focusedField = nextFocusedField
        
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
            
            CommonButton(
                title: "Update",
                isEnabled: self.viewModel.isSubmitButtonEnabled
            ) {
                
                self.focusedField = nil
                
                self.viewModel
                    .update()
                
            }
            .padding(.top, .small)
            .padding(.horizontal, .medium)
            .transition(.move(edge: .bottom)
                .combined(with: .opacity)
                .animation(.bouncy(duration: 0.3))
            )
            .background(Style.shared.background(.primary).source())
            
        }
        
    }
    
}

#Preview {
    
    ProfileScreen(
        viewModel: mockResolve(ProfileViewModel.self)
    )
    .withMockServices()
    
}
