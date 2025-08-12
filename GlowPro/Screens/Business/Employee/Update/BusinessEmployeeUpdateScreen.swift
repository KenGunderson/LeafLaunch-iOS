//
//  BusinessEmployeeUpdateScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/9/25.
//

import SwiftUI

struct BusinessEmployeeUpdateScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case name
        case email
        case phone
        
        var displayName: String {
            switch self {
            case .name: return "Name"
            case .email: return "Email"
            case .phone: return "Phone"
            }
        }
        
    }
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessEmployeeUpdateViewModel
    
    @FocusState private var focusedField: FocusedField?
    
    @State private var isDropdownPresented: Bool = false
    
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
            title: "Invite Employee",
            leftButtonView: backButton
        )
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.large)) {
            
            businessGeneralInformation()
            
        }
        .padding(.horizontal, .large)
        
    }
    
    private func businessGeneralInformation() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("Edit the role of an employee in your business account by filling out the form below.")
                .foregroundStyle(Style.shared.textColor(.title).source())
                .multilineTextAlignment(.leading)
                .appFont(with: .BODY_2)
                .padding(.bottom, .small)
                    
            VStack(spacing: Style.shared.spacing(.small)) {
                
                textField(fieldToFocus: .name)
                textField(fieldToFocus: .email)
                textField(fieldToFocus: .phone)
                rolePicker()
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        
        Text(title)
            .foregroundStyle(Style.shared.textColor(.title).source())
            .appFont(with: .TITLE_6)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        
    }
    
    @ViewBuilder
    private func rolePicker() -> some View {
        
        VStack(spacing: Style.shared.spacing(.custom(6))) {
            
            Text("Role")
                .appFont(with: .TITLE_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CommonDropDownMenu(
                options: Role.allCases,
                backgroundStyle: .color(.clear),
                shadow: .none,
                textHorizontalPadding: .small,
                selectedOption: self.$viewModel.selectedRole,
                showDropDown: self.$isDropdownPresented
            )
            .appBorder(cornerRadius: .small, lineWidth: 1.5)
            
        }
        .padding(.top, .small)
        
    }
    
    private func textField(fieldToFocus: FocusedField) -> some View {
        
        var text: Binding<String> = .constant("")
        var isFocused: Bool = false
        var keyboardType: UIKeyboardType = .default
        var textContentType: UITextContentType = .organizationName
        
        let placeholder: String = fieldToFocus.displayName
        
        switch fieldToFocus {
        case .name:
            
            text = self.$viewModel.name
            isFocused = self.focusedField == .name
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
                backgroundColor: Style.shared.background(.tertiary),
                textFieldFont: .TITLE_4
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
            .disabled(true)
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if self.focusedField == nil {
            
            CommonButton(title: "Update",
                         isEnabled: self.viewModel.isSaveButtonEnabled) {
                
                self.viewModel
                    .updateEmployee()
                
            }
            .padding(.top, .small)
            .padding(.horizontal, .large)
            .transition(.move(edge: .bottom)
                .combined(with: .opacity)
                .animation(.smooth(duration: 0.3))
            )
            .background(Style.shared.background(.primary).source())
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessEmployeeUpdateViewModel.self)
        .setup(
            businessId: MockModels.ID.business1,
            employeeId: MockModels.ID.employee1
        )
    
    BusinessEmployeeUpdateScreen(viewModel: viewModel)
        .withMockServices()
    
}
