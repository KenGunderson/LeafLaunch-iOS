//
//  BusinessEmployeeCreateScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/9/25.
//

import SwiftUI

enum Role: String,
           CaseIterable,
           Selectable {
    
    var id: String {
        return self.rawValue
    }
    
    case employee
    case frontDesk
    case manager
    case owner
    
    var description: String {
        switch self {
        case .employee: return "Employee"
        case .frontDesk: return "Front Desk"
        case .manager: return "Manager"
        case .owner: return "Owner"
        }
    }
    
}

struct BusinessEmployeeCreateScreen: GPView {
    
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
    
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessEmployeeCreateViewModel
    
    @FocusState private var focusedField: FocusedField?
    
    @State private var isDropdownPresented: Bool = false
    
    var body: some View {
        
        content()
        
        // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            .onAppear {
                
                self.tabBarNavigationService
                    .shouldShowTabBar(false)
                
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
        
        let backButton = BackButton(backgroundColor: .color(.clear)) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Create Employee",
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
            
            sectionTitle("Invite")
            
            Text("You can invite an employee to join your business. They will be able to download the app with the invite code attached to their email.")
                .multilineTextAlignment(.leading)
                .appFont(with: .BODY_B4)
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
            .appFont(with: .TITLE_T8)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        
    }
    
    @ViewBuilder
    private func rolePicker() -> some View {
        
        VStack(spacing: Style.shared.spacing(.custom(6))) {
            
            Text("Role")
                .appFont(with: .TITLE_T4)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CommonDropDownMenu(
                options: Role.allCases,
                backgroundStyle: Style.shared.background(.primary),
                shadow: .none,
                textHorizontalPadding: .small,
                selectedOption: self.$viewModel.selectedRole,
                showDropDown: self.$isDropdownPresented
            )
            .appBorder(cornerRadius: .small, lineWidth: 2.5)
            
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
                foregroundColor: Style.shared.textColor(.title)
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
    private func bottomBar() -> some View {
        
        if self.focusedField == nil {
            
            CommonButton(title: "Create",
                         isEnabled: self.viewModel.isSaveButtonEnabled) {
                
                self.viewModel
                    .createEmployee()
                
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
    
    let viewModel = mockResolve(BusinessEmployeeCreateViewModel.self)
        .setup(businessId: "123")
    
    BusinessEmployeeCreateScreen(viewModel: viewModel)
        .withMockServices()
    
}
