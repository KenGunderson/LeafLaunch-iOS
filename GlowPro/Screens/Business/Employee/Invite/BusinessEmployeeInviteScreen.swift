//
//  BusinessEmployeeInviteScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/9/25.
//

import SwiftUI

struct BusinessEmployeeInviteScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case name
        case email
        
        var displayName: String {
            switch self {
            case .name: return "Name"
            case .email: return "Email"
            }
        }
        
    }
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessEmployeeInviteViewModel
    
    @FocusState private var focusedField: FocusedField?
    
    @State private var isRoleDropdownPresented: Bool = false
    @State private var isLocationDropdownPresented: Bool = false
    @State private var selectedLocations: Set<String> = []
    @State private var selectedRole: Role?
    
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
            .onChange(of: self.selectedLocations) { _, newValue in
                self.viewModel.updateSelectedLocations(Array(newValue))
            }
            .onChange(of: self.selectedRole) { _, newValue in
                self.viewModel.updateSelectedRole(newValue)
            }
            .onChange(of: self.viewModel.selectedLocations) { _, newValue in
                self.selectedLocations = Set(newValue.map(\.name))
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
        
        return NavBarView(
            title: "Invite Employee",
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
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            Text("You can invite an employee to join your business. They will be able to download the app with the invite code attached to their email.")
                .foregroundStyle(Style.shared.textColor(.title).source())
                .multilineTextAlignment(.leading)
                .appFont(with: .BODY_2)
                .padding(.bottom, .small)
                    
            VStack(spacing: Style.shared.spacing(.small)) {
                
                textField(fieldToFocus: .name)
                textField(fieldToFocus: .email)
                locationPicker()
                rolePicker()
                
                Rectangle()
                    .fill(.red)
                    .opacity(0)
                    .frame(height: 45)
            }
            
        }
        
        // Animations
        
        .animation(.spring, value: self.isLocationDropdownPresented)
        .animation(.spring, value: self.isRoleDropdownPresented)
        .animation(.spring, value: self.viewModel.selectedLocations)
        .animation(.spring, value: self.viewModel.selectedRole)
        .animation(.spring, value: self.selectedRole)
        .animation(.spring, value: self.selectedLocations)
        
    }
    
    private func textField(fieldToFocus: FocusedField) -> some View {
        
        var text: Binding<String> = .constant("")
        var isFocused: Bool = false
        var keyboardType: UIKeyboardType = .default
        var textContentType: UITextContentType = .organizationName
        let isEnabled = !self.viewModel.isUpdatingEmployeeContext
        
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
        }
        
        return TextField("", text: text)
            .titleUnderlineTextFieldStyle(
                text: text.wrappedValue,
                title: placeholder,
                style: .border(cornerRadius: .custom(6)),
                isFocused: isFocused,
                foregroundColor: Style.shared.textColor(.title),
                backgroundColor: isEnabled ? .color(.clear) : Style.shared.background(.quaternary),
                textFieldFont: .BODY_3
            )
            .focused(self.$focusedField, equals: fieldToFocus)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .submitLabel(fieldToFocus == .email ? .done : .next)
            .textInputAutocapitalization(fieldToFocus == .email ? .none : .words)
            .autocorrectionDisabled(true)
            .appOnTapGesture {
                self.focusedField = fieldToFocus
            }
            .allowsHitTesting(isEnabled)
        
    }
    
    private func handleOnSubmit() {
        
        var nextFocusedField: FocusedField? = nil
        
        switch self.focusedField {
        case .name: nextFocusedField = .email
        case .email: nextFocusedField = nil
        default: nextFocusedField = nil
        }
        
        self.focusedField = nextFocusedField
        
    }
    
    @ViewBuilder
    private func locationPicker() -> some View {
        
        let locations = self.viewModel.eligibleLocations
        let locationNames = locations.map(\.name)
        
        if !locations.isEmpty {
            
            VStack(spacing: Style.shared.spacing(.custom(6))) {
                
                Text("Eligable Locations (Optional)")
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                CommonDropDownMultiSelectMenu(
                    options: locationNames,
                    backgroundStyle: .color(.minimumOpacity),
                    shadow: .none,
                    textHorizontalPadding: .small,
                    animation: .spring,
                    selectedOptions: self.$selectedLocations,
                    showDropDown: self.$isLocationDropdownPresented
                )
                .appBorder(cornerRadius: .small, lineWidth: 1.5)
                
            }
            .padding(.top, .small)
            
        }
        
    }
    
    @ViewBuilder
    private func rolePicker() -> some View {
        
        let locations = self.viewModel.eligibleLocations
        
        if !locations.isEmpty {
            
            VStack(spacing: Style.shared.spacing(.custom(6))) {
                
                Text("Role (Optional)")
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                CommonDropDownMenu(
                    options: viewModel.locationRoles,
                    backgroundStyle: .color(.minimumOpacity),
                    shadow: .none,
                    textHorizontalPadding: .small,
                    animation: .spring,
                    selectedOption: self.$selectedRole,
                    showDropDown: self.$isRoleDropdownPresented
                )
                .appBorder(cornerRadius: .small, lineWidth: 1.5)
                
            }
            .padding(.top, .small)
            
        }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if self.focusedField == nil {
            
            CommonButton(title: "Invite",
                         isEnabled: self.viewModel.isSaveButtonEnabled) {
                
                self.viewModel
                    .inviteEmployee()
                
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
    
    let viewModel = mockResolve(BusinessEmployeeInviteViewModel.self)
        .setup(
            businessId: MockModels.ID.business1,
            context: .newEmployee
        )
    
    BusinessEmployeeInviteScreen(viewModel: viewModel)
        .withMockServices()
    
}
