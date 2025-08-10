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
        
        let backButton = BackButton(backgroundColor: .color(.clear)) {
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
            
            Text("You can invite an employee to join your business. They will be able to download the app with the invite code attached to their email.")
                .foregroundStyle(Style.shared.textColor(.title).source())
                .multilineTextAlignment(.leading)
                .appFont(with: .BODY_2)
                .padding(.bottom, .small)
                    
            VStack(spacing: Style.shared.spacing(.small)) {
                
                textField(fieldToFocus: .name)
                textField(fieldToFocus: .email)
                
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
        }
        
        return TextField("", text: text)
            .titleUnderlineTextFieldStyle(
                text: text.wrappedValue,
                title: placeholder,
                style: .border(cornerRadius: .custom(6)),
                isFocused: isFocused,
                foregroundColor: Style.shared.textColor(.title),
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
    
    let viewModel = mockResolve(BusinessEmployeeInviteViewModel.self)
        .setup(businessId: MockModels.ID.business1)
    
    BusinessEmployeeInviteScreen(viewModel: viewModel)
        .withMockServices()
    
}
