//
//  BusinessEditDetails.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 6/24/25.
//

import SwiftUI

struct BusinessEditDetailsScreen: GPView {
    
    enum FocusedField: Hashable {
        
        case businessName
        case email
        case phone
        case street
        case street2
        case city
        case state
        case zip
        
        var displayName: String {
            switch self {
            case .businessName: return "Business Name"
            case .email: return "Email"
            case .phone: return "Phone"
            case .street: return "Street"
            case .street2: return "Street 2"
            case .city: return "City"
            case .state: return "State"
            case .zip: return "Zip"
            }
        }
        
    }
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessEditDetailsViewModel
    
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
            title: "Edit Business",
            leftButtonView: backButton
        )
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.large)) {
            
            businessGeneralInformation()
            businessAddress()
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func businessGeneralInformation() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            sectionTitle("General Information")
            
            AppCardView {
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    textField(fieldToFocus: .businessName)
                    textField(fieldToFocus: .email)
                    textField(fieldToFocus: .phone)
                    
                }
                
            }
            
        }
        
    }
    
    private func businessAddress() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            sectionTitle("Business Address")
            
            AppCardView {
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    textField(fieldToFocus: .street)
                    textField(fieldToFocus: .street2)
                    textField(fieldToFocus: .city)
                    
                    HStack {
                        
                        textField(fieldToFocus: .state)
                        textField(fieldToFocus: .zip)
                        
                    }
                    
                }
                
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
        case .businessName:
            
            text = self.$viewModel.name
            isFocused = self.focusedField == .businessName
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
            
        case .street:
            
            text = self.$viewModel.street
            isFocused = self.focusedField == .street
            keyboardType = .default
            textContentType = .streetAddressLine1
            
        case .street2:
            
            text = self.$viewModel.street2
            isFocused = self.focusedField == .street2
            keyboardType = .default
            textContentType = .streetAddressLine2
            
        case .city:
            
            text = self.$viewModel.city
            isFocused = self.focusedField == .city
            keyboardType = .default
            textContentType = .addressCity
            
        case .state:
            
            text = self.$viewModel.state
            isFocused = self.focusedField == .state
            keyboardType = .default
            textContentType = .addressState
            
        case .zip:
            
            text = self.$viewModel.zip
            isFocused = self.focusedField == .zip
            keyboardType = .default
            textContentType = .postalCode
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
            
            CommonButton(title: "Save") {
                
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
    
    let viewModel = mockResolve(BusinessEditDetailsViewModel.self)
        .setup(businessId: MockModels.ID.business1)
    
    BusinessEditDetailsScreen(viewModel: viewModel)
        .withMockServices()
    
}
